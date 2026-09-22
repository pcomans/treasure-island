"""Compare retained native source-surface records without hiding stable changes.

Inputs are decoded JSON objects: {source_key: {field: value}}. Within each run
all fields are significant. Only the four established record-level identities
are excluded across runs. No numeric conversion, tolerance or geometry logic.
"""

_TRANSIENT_FIELDS = frozenset(("instance_id", "mesh_instance_id", "mesh_rid", "body_rid"))


def compare_source_surfaces(before, after, prior_before, prior_after, *, max_differences=16):
    """Return bounded named differences; callers retain independent source gates.

    Input dictionaries are never modified. A truncated result is still a FAIL;
    it makes no claim about the total number of differences. Record counts and
    source-key expectations belong to the caller's target-specific contract.
    """
    if type(max_differences) is not int or not 1 <= max_differences <= 64:
        raise ValueError("max_differences must be an integer from 1 through 64")
    differences = []
    truncated = False

    def report(comparison, path, reason, left=None, right=None):
        nonlocal truncated
        if len(differences) >= max_differences:
            truncated = True
            return
        item = {"comparison": comparison, "path": path[:480], "reason": reason}
        if reason == "type_changed":
            item.update(prior_type=type(left).__name__, current_type=type(right).__name__)
        differences.append(item)

    def child(path, key):
        return path + "/" + str(key).replace("~", "~0").replace("/", "~1")

    def compare(left, right, comparison, path=""):
        if truncated:
            return
        if type(left) is not type(right):
            report(comparison, path, "type_changed", left, right)
        elif type(left) is dict:
            if any(type(key) is not str for key in (*left, *right)):
                report(comparison, path, "expected_string_field_names")
                return
            for key in left:
                if key not in right:
                    report(comparison, child(path, key), "missing_key")
                else:
                    compare(left[key], right[key], comparison, child(path, key))
                if truncated:
                    return
            for key in right:
                if key not in left:
                    report(comparison, child(path, key), "added_key")
                if truncated:
                    return
        elif type(left) is list:
            if len(left) != len(right):
                report(comparison, path, "length_changed")
            for index, (old, new) in enumerate(zip(left, right)):
                compare(old, new, comparison, child(path, index))
                if truncated:
                    return
        elif left != right:
            report(comparison, path, "value_changed")

    for label, records in (("before", before), ("after", after),
                           ("prior_before", prior_before), ("prior_after", prior_after)):
        if type(records) is not dict:
            report(label, "", "expected_record_dictionary")
            continue
        for key, record in records.items():
            if type(key) is not str or type(record) is not dict:
                report(label, child("", key), "expected_named_record_dictionary")
    if not differences:
        compare(before, after, "current_within_run")
        compare(prior_before, prior_after, "prior_within_run")
        stable = lambda records: {
            key: {field: value for field, value in row.items() if field not in _TRANSIENT_FIELDS}
            for key, row in records.items()
        }
        compare(stable(prior_before), stable(before), "cross_run_stable")
    return {"ok": not differences, "differences": differences,
            "differences_truncated": truncated,
            "cross_run_excluded_fields": sorted(_TRANSIENT_FIELDS)}
