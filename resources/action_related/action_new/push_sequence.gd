extends Action
class_name PushSequenceToNPC

enum PushMode{
	INSTANT,
	AFTER_ACTION,
	AFTER_SEQUENCE,
}

@export var _target_name: String
@export var _sequence: Sequence
@export var _mode : PushMode = PushMode.INSTANT

func create(character_: NPCActions, target_name: String, sequence: Sequence, mode := PushMode.INSTANT) -> Action:
	character = character_
	_target_name = target_name
	_sequence = sequence
	_mode = mode
	return self

func open() -> void:
	var target : NPCActions = NpcRegistry.get_npc(_target_name)
	if not target:
		push_error("Target NPC not found: %s" % _target_name)
		_complete()
		return

	for act in _sequence._actions:
		act.character = target

	match _mode:
		PushMode.INSTANT:
			target.sequence_controller.push_instant(_sequence)
		PushMode.AFTER_ACTION:
			target.sequence_controller.push_after_action(_sequence)
		PushMode.AFTER_SEQUENCE:
			target.sequence_controller.push_after_sequence(_sequence)

	_complete()
