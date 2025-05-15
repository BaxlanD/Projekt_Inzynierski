@tool
extends Resource
class_name TimeBlock


var _parent_schedule: Schedule = null

@export_placeholder("activity") var activity: String:
	set(value):
		activity = value
		_notify_parent()

@export_range(0, 300, 1, "suffix:s") var time: int:
	set(value):
		time = value
		_notify_parent()


func _notify_parent() -> void:
	if _parent_schedule and Engine.is_editor_hint():
		_parent_schedule._on_block_updated()
