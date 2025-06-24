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
	_current_action.action_completed.connect(_on_action_completed)

func get_current_action() -> Action:
	# Flush any actions that timed out without finishing
	while _current_action != null and _current_action.is_timed_out():
		_advance_schedule()
	return _current_action

func _advance_schedule() -> void:
	_current_action.action_completed.disconnect(_on_action_completed)
	_index += 1
	if _index < actions.size():
		_current_action = actions[_index]
		_current_action.action_completed.connect(_on_action_completed)
	else:
		_current_action = null

func _on_action_completed() -> void:
	_advance_schedule()
