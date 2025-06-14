@tool
extends Resource
class_name Schedule

signal progress
signal schedule_changed


const DAY_LENGTH: int = 15
var current: int = 0
var elapsed_time: float = 0

@export var _timeblocks: Array[TimeBlock]:
	set(value):
		_timeblocks = value
		for timeblock in _timeblocks:
			if timeblock != null:
				timeblock._parent_schedule = self


func get_activity_from_schedule(time: int) -> Vector2:
	var total_time: int = 0
	for timeblock in _timeblocks:
		total_time += timeblock.time
		if time < total_time:
			return timeblock.activity
	return Vector2.ZERO


func get_total_duration() -> int:
	var total_time: int = 0
	for timeblock in _timeblocks:
		if timeblock != null:
			total_time += timeblock.time
	return total_time


func _on_block_updated() -> void:
	schedule_changed.emit()
	pass
