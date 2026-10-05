extends RefCounted
## Reads the building catalog (discovery/facades/facade-recognition-catalog.json).

const PATH := "res://discovery/facades/facade-recognition-catalog.json"


static func units() -> Array:
	return (JSON.parse_string(FileAccess.get_file_as_string(PATH)) as Dictionary).units


## The buildings counted in the recognition score.
static func accepted_units() -> Array[Dictionary]:
	var accepted: Array[Dictionary] = []
	for unit: Dictionary in units():
		if unit.get("claim_status", {}).get("reference_recognizable", "") == "accepted":
			accepted.append(unit)
	return accepted


## The catalog entry whose anchor OSM key is source_key, or {}.
static func unit_for(source_key: String) -> Dictionary:
	for unit: Dictionary in units():
		if str(unit.get("anchor_source_key", "")) == source_key:
			return unit
	return {}
