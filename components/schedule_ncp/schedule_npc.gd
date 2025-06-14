extends Node
class_name ScheduleNPC

signal new_shedule_entry_started(target: Vector2)

var schedule: Array[ScheduleEntry] = []
var timer: Timer
var entry_index: int = 0

@export var npc: NPC

func get_current_target() -> Vector2:
	if entry_index < schedule.size():
		return schedule[entry_index].target 
	return Vector2.ZERO

func _ready() -> void:
	for i in get_child_count():
		schedule.append(get_child(i))
		
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true

func start_schedule() -> void:
	_timer_set()

func _timer_set() -> void:
	timer.wait_time = schedule[entry_index].duration
	timer.start()
	new_shedule_entry_started.emit(get_current_target())

func _on_timer_timeout() -> void:
	entry_index += 1
	if entry_index < schedule.size():
		_timer_set()
	else:
		new_shedule_entry_started.emit(get_current_target())
		print("Finished schedule")
