extends Node
class_name ActionSequencer

@export var _stack: Array[Sequence]
var character: Character

func start(character_: Character) -> void:
	## Reverse the stack it make it easier to edit stuff in the editor
	## But be able to pop and push to the back of the array
	character = character_ 
	_stack.reverse()
	for seq in _stack:
		for act in seq._actions:
			act.character = character_
	character_.current_sequence_index = _stack.size() - 1

func get_action() -> Action:
	_flush_done_sequences()
	return _get_action_from_sequence()

func push_sequence(sequence: Sequence) -> void:
	_try_clear_fleeting()
	_stack.push_back(sequence)

func push_lazy_sequence(sequence: Sequence) -> void:
	if _stack.is_empty():
		push_sequence(sequence)
	else:
		var active: Sequence = _stack.pop_back()
		_stack.push_back(sequence)
		_stack.push_back(active)

func erase_sequence(sequence: Sequence) -> void:
	_stack.erase(sequence)

#region Private Methods

func _flush_done_sequences() -> void:
	while _stack.size() > 0:
		var _action: Action = _stack[-1].get_action()
		if _action == null:
			_stack.pop_back()
			if character:
				character.current_sequence_index = _stack.size() - 1
		else:
			break

func _get_action_from_sequence() -> Action:
	if _stack.size() > 0:
		return _stack[-1].get_action()
	return null

func _try_clear_fleeting() -> void:
	if _stack.size() > 0 and _stack[-1].is_fleeting():
		_stack.pop_back()

#endregion
