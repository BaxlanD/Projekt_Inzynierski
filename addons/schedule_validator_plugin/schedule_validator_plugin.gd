@tool
extends EditorPlugin


var validator: ScheduleValidator


func _enter_tree() -> void:
	validator = ScheduleValidator.new()
	add_inspector_plugin(validator)


func _exit_tree() -> void:
	remove_inspector_plugin(validator)
