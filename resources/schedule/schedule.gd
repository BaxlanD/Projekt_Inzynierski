@tool
extends Resource
class_name Schedule


signal schedule_changed


const DAY_LENGTH: int = 10


@export var _timeblocks: Array[TimeBlock]:
	set(value):
		_timeblocks = value
		for timeblock in _timeblocks:
			if timeblock != null:
				timeblock._parent_schedule = self


func get_activity_from_schedule(time: int) -> String:
	var total_time: int = 0
	for timeblock in _timeblocks:
		total_time += timeblock.time
		if time < total_time:
			return timeblock.activity
	return "Out of schedule"


func get_total_duration() -> int:
	var total_time: int = 0
	for timeblock in _timeblocks:
		if timeblock != null:
			total_time += timeblock.time
	return total_time


func _on_block_updated() -> void:
	schedule_changed.emit()
	pass
