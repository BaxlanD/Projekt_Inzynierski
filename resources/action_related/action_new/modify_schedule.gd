extends Action
class_name ModifyScheduleAction

enum Mode { SKIP, CLEAR }

@export var mode: Mode = Mode.SKIP
@export var skip_count: int = 1

func create(character_: NPCActions, mode_: Mode, skip_count_: int = 1) -> ModifyScheduleAction:
	character = character_
	mode = mode_
	skip_count = skip_count_
	return self

func open() -> void:
	super.open()
	match mode:
		Mode.SKIP:
			_skip_sequences(skip_count)
		Mode.CLEAR:
			_clear_schedule()
	_complete()

func _skip_sequences(count: int) -> void:
	if not character or not character.sequence_controller:
		return
	var sequencer := character.sequence_controller._action_sequencer
	if not sequencer:
		return
	for i in range(count):
		if sequencer._stack.size() > 0:
			sequencer._stack.pop_back()
		else:
			break
	character.current_sequence_index = sequencer._stack.size() - 1

func _clear_schedule() -> void:
	if not character or not character.sequence_controller:
		return
	var sequencer := character.sequence_controller._action_sequencer
	if not sequencer:
		return
	sequencer._stack.clear()
	character.current_sequence_index = -1
