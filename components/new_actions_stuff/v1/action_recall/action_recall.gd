extends Node
class_name ActionRecall

var _recall: Array[Action]
var _current_action: Action
var _character: NPCActions

func start(character_: NPCActions) -> void:
	_recall.clear()
	_current_action = null
	_character = character_

func preserve(action: Action) -> void:
	if not action.is_done():
		_recall.push_back(action)
		_current_action = action

func revive() -> Action:
	while not _recall.is_empty() and _recall[-1].is_done():
		print("flushed timed out action in recall")
		_recall.pop_back()
	return _recall.pop_back()
