extends Node
class_name ActionSchedule

@export var actions: Array[Action]

var _current_action: Action
var _index: int

func start(character_: NPCActions) -> void:
	assert(!actions.is_empty(), "Schedule action list is empty")
	for action in actions:
		assert(action, "Null value in Schedule")
		action.character = character_
		
	_index = 0
	_current_action = actions[_index]

func get_current_action() -> Action:
	# Flush any actions that timed out without finishing
	while _current_action and _current_action.is_done():
		_advance_schedule()
	return _current_action

func _advance_schedule() -> void:
	print_rich("[color=green][b]ADVANCE SCHEDULE[/b][/color]")
	_index += 1
	if _index < actions.size():
		_current_action = actions[_index]
	else:
		print_rich("[color=red][b]FINISHED[/b][/color]")
		_current_action = null
