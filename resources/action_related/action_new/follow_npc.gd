extends Action
class_name FollowNPC

@export var target_npc_name: String = ""
@export var follow_distance: float = 40.0
@export var update_interval: float = 0.5
@export var speed_factor: float = 0.8
@export var walk_anim: String = "Walk"
@export var idle_timeout: float = 5.0

var _target_npc: NPCActions = null
var _update_timer: float = 0.0
var _idle_timer: float = 0.0
var _subaction: GoTo = null
var _last_position: Vector2


func create(character_: Character, target_npc_name_: String, distance_: float = 40.0) -> FollowNPC:
	character = character_
	target_npc_name = target_npc_name_
	follow_distance = distance_
	return self


func open() -> void:
	super()

	if target_npc_name.is_empty():
		push_warning("[FollowNPC] No target NPC name provided.")
		_complete()
		return

	var root := character.get_tree().root
	_target_npc = root.find_child(target_npc_name, true, false) as NPCActions

	if not _target_npc:
		push_warning("[FollowNPC] Target NPC not found: " + target_npc_name)
		_complete()
		return

	print("[FollowNPC] %s started following %s" % [character.name, _target_npc.name])

	if character.animated_sprite_2d:
		character.animated_sprite_2d.play(walk_anim)

	_update_timer = update_interval
	_idle_timer = 0.0
	_last_position = character.global_position
	
	_update_target_position()


func update(delta: float) -> void:
	if not _target_npc:
		push_warning("[FollowNPC] Target lost.")
		_complete()
		return

	if _subaction:
		_subaction.update(delta)

	if character.global_position.distance_to(_last_position) < 1.0:
		_idle_timer += delta
	else:
		_idle_timer = 0.0
	_last_position = character.global_position

	if _idle_timer >= idle_timeout:
		print("[FollowNPC] %s stood still too long, ending follow." % character.name)
		_stop_follow()
		_complete()
		return

	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = update_interval
		_update_target_position()


func _update_target_position() -> void:
	if not _target_npc:
		return

	var to_target := _target_npc.global_position - character.global_position
	var distance := to_target.length()

	if distance > follow_distance:
		var dir := to_target.normalized()
		var target_pos := _target_npc.global_position - dir * follow_distance * 0.5

		if _subaction:
			_subaction.close()

		_subaction = GoTo.new().create(character, target_pos)
		_subaction.speed_multiplier = speed_factor
		_subaction.open()
	else:
		character.character_stop()
		if character.animated_sprite_2d:
			character.animated_sprite_2d.play("Idle")


func _stop_follow() -> void:
	if _subaction:
		_subaction.close()
		_subaction = null
	character.character_stop()
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")


func close() -> void:
	_stop_follow()
	super()
	print("[FollowNPC] %s stopped following." % character.name)
