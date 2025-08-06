extends Node
class_name SequenceController

@export var _action_sequencer: ActionSequencer

var _started: bool = false
var _elapsed_time: float
var _current_action: Action

func start(character: NPCActions) -> void:
	assert(_action_sequencer)
	_started = true
	_elapsed_time = 0.0
	_action_sequencer.start(character)
	_open_action()

func update(delta: float) -> void:
	if _started:
		_handle_update(delta)

func push_instant(seq: Sequence) -> void:
	_action_sequencer.push_sequence(seq)
	if _current_action:
		_current_action.close()
	else:
		_open_action()

func push_after_action(seq: Sequence) -> void:
	_action_sequencer.push_sequence(seq)
	if _current_action == null:
		_open_action()

func push_after_sequence(seq: Sequence) -> void:
	_action_sequencer.push_lazy_sequence(seq)
	if _current_action == null:
		_open_action()

func clear_sequence(seq: Sequence) -> void:
	_action_sequencer.erase_sequence(seq)

func get_time() -> float:
	return _elapsed_time

#region Private Methods

func _open_action() -> void:
	_current_action = _action_sequencer.get_action()
	if _current_action:
		_current_action.action_closed.connect(_on_action_closed)
		_current_action.open()
	else:
		print("Sequencer Finished")

func _on_action_closed() -> void:
	_current_action.action_closed.disconnect(_on_action_closed)
	_current_action = null
	_open_action()

func _handle_update(delta: float) -> void:
	_elapsed_time += delta
	if _current_action:
		_current_action.update(delta)

#endregion 
