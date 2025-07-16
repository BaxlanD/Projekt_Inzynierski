extends Action
class_name Assert

enum Op{
	EQUALS,
	NOT_EQUALS,
	SMALLER,
	SMALLER_OR_EQUALS,
	BIGGER_OR_EQUALS,
	BIGGER,
}

enum PushMode{
	INSTANT,
	AFTER_ACTION,
	AFTER_SEQUENCE,
}

@export var retain: Retain
@export var operation: Op
@export var value: int
@export var mode: PushMode
@export var fallback_sequence: Sequence


func create(character_: NPCActions, retain_: Retain, operation_: Op, value_: int, mode_: PushMode, fallback_: Sequence) -> Assert:
	character = character_
	retain = retain_
	operation = operation_
	value = value_
	mode = mode_
	fallback_sequence = fallback_
	return self

func open() -> void:
	var result: bool
	match operation:
		Op.EQUALS:
			result = retain.get_value() == value
		Op.NOT_EQUALS:
			result = retain.get_value() != value
		Op.SMALLER:
			result = retain.get_value() < value
		Op.SMALLER_OR_EQUALS:
			result = retain.get_value() <= value
		Op.BIGGER_OR_EQUALS:
			result = retain.get_value() >= value
		Op.BIGGER:
			result = retain.get_value() > value
	
	if not result:
		fallback_sequence.initialize_with_character(character)
		match mode:
			PushMode.INSTANT:
				character.sequence_controller.push_instant(fallback_sequence)
			PushMode.INSTANT:
				character.sequence_controller.push_after_action(fallback_sequence)
			PushMode.INSTANT:
				character.sequence_controller.push_after_sequence(fallback_sequence)
	
	_complete()

func update(_delta: float) -> void:
	assert(false) # Shouldn't ever be called

func close() -> void:
	super()
