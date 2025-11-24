extends GoToAnd
class_name CallGrelda

@export var grelda_name: String = "NPC_Grelda"
@export var anim_self: String = "Talk"
@export var anim_target: String = "Talk"
@export var anim_duration: float = 3.0
@export var offset_distance: float = 30.0
@export var start_distance_threshold: float = 5.0

var _grelda_ref: NPCActions = null
var _phase: int = 0
var _timer: float = 0.0
var _grelda_target_pos: Vector2
var _grelda_called: bool = false


func create(character_: Character, where_: Vector2, grelda_name_: String = "", anim_self_: String = "Talk", anim_target_: String = "Talk", duration_: float = 3.0) -> CallGrelda:
	super._create(character_, where_)
	if grelda_name_ != "":
		grelda_name = grelda_name_
	anim_self = anim_self_
	anim_target = anim_target_
	anim_duration = duration_
	return self


func open() -> void:
	super()
	_phase = 0
	_timer = anim_duration
	_grelda_called = false

	for npc in character.get_tree().get_nodes_in_group("NPCs"):
		if npc.name == grelda_name:
			_grelda_ref = npc
			break

	if _grelda_ref == null:
		push_warning("Grelda not found!")
		print("[CallGrelda] Grelda not found — skipping action.")
		_complete()
		return

	var direction := (character.global_position - _grelda_ref.global_position).normalized()
	_grelda_target_pos = character.global_position - direction * offset_distance
	print("[CallGrelda] Target pos for Grelda set to:", _grelda_target_pos)
	
	_call_grelda()


func update(delta: float) -> void:
	if _subaction:
		super(delta)
		return

	match _phase:
		0:
			if not _grelda_ref:
				push_warning("Grelda reference lost — ending.")
				_complete()
				return

			var dist := _grelda_ref.global_position.distance_to(_grelda_target_pos)
			if dist <= start_distance_threshold and not _grelda_called:
				print("[CallGrelda] Grelda is close enough (%.2f), starting conversation." % dist)
				_start_conversation()
			return

		1:
			_timer -= delta
			if _timer <= 0.0:
				_end_conversation()


func _call_grelda() -> void:
	if not _grelda_ref or not _grelda_ref.sequence_controller:
		print("[CallGrelda] Cannot call Grelda — invalid reference or no controller.")
		_complete()
		return

	if _grelda_ref.sequence_controller._current_action:
		print("[CallGrelda] Grelda is busy, skipping call.")
		_complete()
		return

	# Grelda idzie w kierunku ustalonego punktu
	var anim_action := AnimWith.new()
	anim_action.create(_grelda_ref, _grelda_target_pos, character.name, anim_duration)
	anim_action.anim_self = anim_target
	anim_action.anim_target = anim_self

	var seq := Sequence.new().with_fleeting().from_actions([anim_action])
	_grelda_ref.sequence_controller.push_instant(seq)

	print("[CallGrelda] Grelda started moving to %s's position" % character.name)


func _start_conversation() -> void:
	if not _grelda_ref:
		print("[CallGrelda] No Grelda ref — cannot start conversation.")
		_complete()
		return

	_phase = 1
	_timer = anim_duration

	_grelda_ref.on_interaction_started(anim_target)
	character.on_interaction_started(anim_self)

	print("[CallGrelda] Conversation started between %s and %s" % [character.name, _grelda_ref.name])


func _end_conversation() -> void:
	if _grelda_ref:
		_grelda_ref.on_interaction_ended()
	character.on_interaction_ended()

	print("[CallGrelda] %s finished conversation with %s" % [character.name, _grelda_ref.name])
	_complete()
