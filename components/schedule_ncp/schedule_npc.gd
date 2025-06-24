extends Node
class_name ScheduleNPC

signal new_shedule_entry_started

var schedule: Array[ScheduleEntry] = []
var timer: Timer
var entry_index: int = 0

@export var npc: NPC

func get_current_action() -> ActionD:
	if entry_index < schedule.size():
		return schedule[entry_index].action.copy()
	return ActionD.new()

func _ready() -> void:
	for i in get_child_count():
		schedule.append(get_child(i))
		schedule[i].action.character = npc
		
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true

func start_schedule() -> void:
	_timer_set()

func _timer_set() -> void:
	var time := schedule[entry_index].duration
	timer.wait_time = time
	timer.start()
	new_shedule_entry_started.emit()

func _on_timer_timeout() -> void:
	entry_index += 1
	if entry_index < schedule.size():
		_timer_set()
	else:
		new_shedule_entry_started.emit()
		print("Finished schedule")
