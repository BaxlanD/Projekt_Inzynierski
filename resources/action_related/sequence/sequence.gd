extends Resource
class_name Sequence

@export var _fleeting: bool = false
@export var _actions: Array[Action]
@export var sequence_name: String = "Idle"

func get_action() -> Action:
	_flush_done_actions()
	return _get_from_front()

func is_fleeting() -> bool:
	return _fleeting

## Below Methods intended to be used during sequence creation
## Should not be called on existing actions
func from_actions(list: Array[Action]) -> Sequence:
	for action in list:
		_actions.push_back(action)
	return self

func initialize_with_character(character: NPCActions) -> void:
	for action in _actions:
		action.character = character

func with_fleeting() -> Sequence:
	_fleeting = true
	return self

#region Private Methods

func _flush_done_actions() -> void:
	while _actions.size() > 0 and _actions[0].is_done():
		_actions.pop_front()

func _get_from_front() -> Action:
	if _actions.size() > 0:
		if _actions[0].is_fleeting():
			return _actions.pop_front()
		else:
			return _actions[0]
	return null

#endregion
