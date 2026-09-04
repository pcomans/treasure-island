const SUPPORTED_KEYWORDS = new Set([
  "$defs",
  "$id",
  "$ref",
  "$schema",
  "additionalProperties",
  "anyOf",
  "const",
  "enum",
  "items",
  "maxItems",
  "maximum",
  "minItems",
  "minimum",
  "minLength",
  "pattern",
  "properties",
  "required",
  "title",
  "type",
  "uniqueItems",
]);
const JSON_TYPES = new Set(["array", "boolean", "integer", "null", "number", "object", "string"]);

function isObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (isObject(value)) {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, child]) => [key, canonical(child)]),
    );
  }
  return value;
}

function equalJson(left, right) {
  return JSON.stringify(canonical(left)) === JSON.stringify(canonical(right));
}

function pointerValue(root, reference) {
  if (!reference.startsWith("#/")) return undefined;
  let value = root;
  for (const encoded of reference.slice(2).split("/")) {
    const key = encoded.replaceAll("~1", "/").replaceAll("~0", "~");
    if (!isObject(value) || !Object.hasOwn(value, key)) return undefined;
    value = value[key];
  }
  return value;
}

function keywordType(condition, errors, path, message) {
  if (!condition) errors.push(`${path}: ${message}`);
}

export function schemaDocumentErrors(root) {
  const errors = [];
  const visited = new Set();

  function visit(schema, path) {
    if (!isObject(schema)) {
      errors.push(`${path}: schema must be an object`);
      return;
    }
    if (visited.has(schema)) return;
    visited.add(schema);
    for (const keyword of Object.keys(schema)) {
      if (!SUPPORTED_KEYWORDS.has(keyword)) errors.push(`${path}: unsupported schema keyword ${keyword}`);
    }
    if (Object.hasOwn(schema, "$schema")) keywordType(typeof schema.$schema === "string", errors, path, "$schema must be a string");
    if (Object.hasOwn(schema, "$id")) keywordType(typeof schema.$id === "string", errors, path, "$id must be a string");
    if (Object.hasOwn(schema, "title")) keywordType(typeof schema.title === "string", errors, path, "title must be a string");
    if (Object.hasOwn(schema, "$ref")) {
      keywordType(typeof schema.$ref === "string", errors, path, "$ref must be a string");
      if (typeof schema.$ref === "string") {
        keywordType(schema.$ref.startsWith("#/$defs/"), errors, path, `only local $defs references are supported: ${schema.$ref}`);
        keywordType(isObject(pointerValue(root, schema.$ref)), errors, path, `unresolved $ref ${schema.$ref}`);
      }
    }
    if (Object.hasOwn(schema, "type")) {
      const types = Array.isArray(schema.type) ? schema.type : [schema.type];
      keywordType(types.length > 0 && types.every((type) => JSON_TYPES.has(type)), errors, path, `invalid type ${JSON.stringify(schema.type)}`);
      keywordType(new Set(types).size === types.length, errors, path, "type array contains duplicates");
    }
    if (Object.hasOwn(schema, "enum")) keywordType(Array.isArray(schema.enum) && schema.enum.length > 0, errors, path, "enum must be a non-empty array");
    if (Object.hasOwn(schema, "required")) {
      keywordType(Array.isArray(schema.required) && schema.required.every((key) => typeof key === "string"), errors, path, "required must be an array of strings");
      if (Array.isArray(schema.required)) keywordType(new Set(schema.required).size === schema.required.length, errors, path, "required contains duplicates");
    }
    if (Object.hasOwn(schema, "additionalProperties")) keywordType(typeof schema.additionalProperties === "boolean", errors, path, "only boolean additionalProperties is supported");
    for (const keyword of ["minItems", "maxItems", "minLength"]) {
      if (Object.hasOwn(schema, keyword)) keywordType(Number.isInteger(schema[keyword]) && schema[keyword] >= 0, errors, path, `${keyword} must be a non-negative integer`);
    }
    for (const keyword of ["minimum", "maximum"]) {
      if (Object.hasOwn(schema, keyword)) keywordType(Number.isFinite(schema[keyword]), errors, path, `${keyword} must be finite`);
    }
    if (Number.isInteger(schema.minItems) && Number.isInteger(schema.maxItems)) keywordType(schema.minItems <= schema.maxItems, errors, path, "minItems exceeds maxItems");
    if (Object.hasOwn(schema, "uniqueItems")) keywordType(typeof schema.uniqueItems === "boolean", errors, path, "uniqueItems must be boolean");
    if (Object.hasOwn(schema, "pattern")) {
      keywordType(typeof schema.pattern === "string", errors, path, "pattern must be a string");
      if (typeof schema.pattern === "string") {
        try {
          new RegExp(schema.pattern, "u");
        } catch (error) {
          errors.push(`${path}: invalid pattern ${schema.pattern}: ${error.message}`);
        }
      }
    }
    if (Object.hasOwn(schema, "properties")) {
      keywordType(isObject(schema.properties), errors, path, "properties must be an object");
      if (isObject(schema.properties)) {
        for (const [key, child] of Object.entries(schema.properties)) visit(child, `${path}.properties.${key}`);
      }
    }
    if (Object.hasOwn(schema, "$defs")) {
      keywordType(isObject(schema.$defs), errors, path, "$defs must be an object");
      if (isObject(schema.$defs)) {
        for (const [key, child] of Object.entries(schema.$defs)) visit(child, `${path}.$defs.${key}`);
      }
    }
    if (Object.hasOwn(schema, "items")) visit(schema.items, `${path}.items`);
    if (Object.hasOwn(schema, "anyOf")) {
      keywordType(Array.isArray(schema.anyOf) && schema.anyOf.length > 0, errors, path, "anyOf must be a non-empty array");
      if (Array.isArray(schema.anyOf)) schema.anyOf.forEach((child, index) => visit(child, `${path}.anyOf[${index}]`));
    }
  }

  visit(root, "$schema");
  return errors;
}

export function assertSchemaDocument(root, label = "JSON Schema") {
  const errors = schemaDocumentErrors(root);
  if (errors.length > 0) throw new Error(`${label} is invalid for the dependency-free validator:\n${errors.join("\n")}`);
}

function matchesType(value, type) {
  if (type === "null") return value === null;
  if (type === "array") return Array.isArray(value);
  if (type === "object") return isObject(value);
  if (type === "integer") return Number.isInteger(value);
  if (type === "number") return Number.isFinite(value);
  return typeof value === type;
}

export function jsonSchemaErrors(instance, root) {
  assertSchemaDocument(root);
  const errors = [];

  function validate(value, schema, path) {
    if (typeof schema.$ref === "string") validate(value, pointerValue(root, schema.$ref), path);
    if (Array.isArray(schema.anyOf)) {
      const matches = schema.anyOf.filter((candidate) => {
        const before = errors.length;
        validate(value, candidate, path);
        const passed = errors.length === before;
        errors.splice(before);
        return passed;
      });
      if (matches.length === 0) errors.push(`${path}: does not match any anyOf branch`);
    }
    if (Object.hasOwn(schema, "const") && !equalJson(value, schema.const)) errors.push(`${path}: does not equal const ${JSON.stringify(schema.const)}`);
    if (Array.isArray(schema.enum) && !schema.enum.some((candidate) => equalJson(value, candidate))) errors.push(`${path}: value ${JSON.stringify(value)} is outside enum`);
    if (Object.hasOwn(schema, "type")) {
      const types = Array.isArray(schema.type) ? schema.type : [schema.type];
      if (!types.some((type) => matchesType(value, type))) {
        errors.push(`${path}: expected type ${types.join("|")}`);
        return;
      }
    }
    if (isObject(value)) {
      if (Array.isArray(schema.required)) {
        for (const key of schema.required) if (!Object.hasOwn(value, key)) errors.push(`${path}: missing required property ${key}`);
      }
      if (isObject(schema.properties)) {
        for (const [key, child] of Object.entries(schema.properties)) if (Object.hasOwn(value, key)) validate(value[key], child, `${path}.${key}`);
        if (schema.additionalProperties === false) {
          for (const key of Object.keys(value)) if (!Object.hasOwn(schema.properties, key)) errors.push(`${path}: additional property ${key} is forbidden`);
        }
      } else if (schema.additionalProperties === false && Object.keys(value).length > 0) {
        errors.push(`${path}: additional properties are forbidden`);
      }
    }
    if (Array.isArray(value)) {
      if (Number.isInteger(schema.minItems) && value.length < schema.minItems) errors.push(`${path}: has ${value.length} items; minimum is ${schema.minItems}`);
      if (Number.isInteger(schema.maxItems) && value.length > schema.maxItems) errors.push(`${path}: has ${value.length} items; maximum is ${schema.maxItems}`);
      if (schema.uniqueItems === true) {
        for (let left = 0; left < value.length; left += 1) {
          for (let right = left + 1; right < value.length; right += 1) {
            if (equalJson(value[left], value[right])) errors.push(`${path}: items ${left} and ${right} are not unique`);
          }
        }
      }
      if (isObject(schema.items)) value.forEach((child, index) => validate(child, schema.items, `${path}[${index}]`));
    }
    if (typeof value === "string") {
      if (Number.isInteger(schema.minLength) && [...value].length < schema.minLength) errors.push(`${path}: string is shorter than ${schema.minLength}`);
      if (typeof schema.pattern === "string" && !new RegExp(schema.pattern, "u").test(value)) errors.push(`${path}: string does not match ${schema.pattern}`);
    }
    if (typeof value === "number") {
      if (Number.isFinite(schema.minimum) && value < schema.minimum) errors.push(`${path}: number is below minimum ${schema.minimum}`);
      if (Number.isFinite(schema.maximum) && value > schema.maximum) errors.push(`${path}: number exceeds maximum ${schema.maximum}`);
    }
  }

  validate(instance, root, "$catalog");
  return errors;
}

export function assertJsonSchema(instance, root, label = "JSON instance") {
  const errors = jsonSchemaErrors(instance, root);
  if (errors.length > 0) throw new Error(`${label} violates its JSON Schema:\n${errors.join("\n")}`);
}
