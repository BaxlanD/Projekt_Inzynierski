extends EditorInspectorPlugin
class_name ScheduleValidator

var schedule: Schedule
var total_duration: int
var label: Label


func _can_handle(object: Object) -> bool:
	return object is Schedule


func _parse_begin(object: Object) -> void:
	schedule = object as Schedule
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_custom_control(label)
	
	if schedule.schedule_changed.is_connected(_on_schedule_changed):
		schedule.schedule_changed.disconnect(_on_schedule_changed)
	schedule.schedule_changed.connect(_on_schedule_changed)
	
	_update_label()


func _on_schedule_changed():
	call_deferred("_update_label")


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	call_deferred("_update_label")
	return false


func _update_label() -> void:
	total_duration = schedule.get_total_duration()
	label.text = "Schedule Total Time: %.2f / %.2f " % [total_duration, schedule.DAY_LENGTH]
	
	if total_duration < schedule.DAY_LENGTH:
		label.add_theme_color_override("font_color", Color.YELLOW)
	elif total_duration > schedule.DAY_LENGTH:
		label.add_theme_color_override("font_color", Color.RED)
	else:
		label.add_theme_color_override("font_color", Color.GREEN)
