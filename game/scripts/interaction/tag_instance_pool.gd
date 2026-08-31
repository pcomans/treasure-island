class_name TagInstancePool
extends Node3D

signal active_count_changed(count: int)
signal oldest_tag_removed

@export_range(1, 256, 1) var session_limit := 64

var _tags: Array[Decal] = []


func _ready() -> void:
	top_level = true


func add_tag(tag: Decal) -> void:
	if _tags.size() >= session_limit:
		var oldest: Decal = _tags.pop_front() as Decal
		if is_instance_valid(oldest):
			oldest.queue_free()
		oldest_tag_removed.emit()
	add_child(tag)
	_tags.append(tag)
	active_count_changed.emit(_tags.size())


func active_count() -> int:
	return _tags.size()


func clear_tags() -> void:
	for tag: Decal in _tags:
		if is_instance_valid(tag):
			tag.queue_free()
	_tags.clear()
	active_count_changed.emit(0)
