extends Node
class_name SequenceController

@export var _action_sequencer: ActionSequencer
@export var _game_clock: GameClock

var _started: bool = false
var _current_action: Action
var _char: Character

func start(character: Character) -> void:
	assert(_action_sequencer)
	_char = character
	_started = true
	_game_clock.start_clock.connect(_on_start_clock)
	_game_clock.stop_clock.connect(_on_stop_clock)
	_action_sequencer.start(character)
	_open_action()

func update(delta: float) -> void:
	if _started and _game_clock.allow_processing(self):
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
	return _game_clock.get_game_time()

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
	if _current_action:
		_current_action.update(delta)

func _on_start_clock() -> void:
	_started = true
	_char.animated_sprite_2d.play()

func _on_stop_clock() -> void:
	if _game_clock.allow_processing(self):
		return
	else:
		_started = false
		_char.animated_sprite_2d.pause()

#endregion 
