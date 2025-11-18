extends GoToAnd
class_name AnimWith

@export var anim_self: String = "Talk"
@export var anim_target: String = "Talk"
@export var anim_duration: float = 3.0
@export var target_name: String = ""

var _timer: float = 0.0
var _phase_started: bool = false
var _target_ref: NPCActions = null


func create(character_: NPCActions, where_: Vector2, target_name_: String = "", duration_: float = 3.0) -> AnimWith:
	super._create(character_, where_)
	target_name = target_name_
	anim_duration = duration_
	return self


func open() -> void:
	super()
	_phase_started = false
	_timer = anim_duration
	_target_ref = _find_target()



func update(delta: float) -> void:
	if _subaction:
		super(delta)
		return

	if not _phase_started:
		_start_anim()
		return

	_timer -= delta
	if _timer <= 0.0:
		_end_anim()


func _find_target() -> NPCActions:
	for npc in character.get_tree().get_nodes_in_group("NPCs"):
		if npc.name == target_name:
			return npc
	return null


func _push_partner_sequence(target: NPCActions) -> void:
	var seq_controller : SequenceController = target.get_node_or_null("SequenceController")
	if not seq_controller:
		push_warning("%s has no SequenceController!" % target.name)
		return

	var seq := Sequence.new()
	
	var partner_action := preload("res://resources/action_related/action_new/partner_anim.gd").new().create(target, anim_target, anim_duration)

	seq._actions.append(partner_action)

	seq_controller.push_instant(seq)

	print("Pushed new sequence to partner:", target.name)


func _start_anim() -> void:
	_phase_started = true
	character.velocity = Vector2.ZERO
	
	if _target_ref:
		_push_partner_sequence(_target_ref)

	if character.animated_sprite_2d and anim_self != "":
		character.animated_sprite_2d.play(anim_self)


func _end_anim() -> void:
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")
	_complete()


func close() -> void:
	character.velocity = Vector2.ZERO
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")
	super()
