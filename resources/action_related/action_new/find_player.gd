extends GoToAnd
class_name FindPlayer

@export var anim_self: String = "Talk"
@export var anim_duration: float = 3.0
@export var detection_radius: float = 20.0
@export var approach_distance: float = 25.0
@export var search_timeout: float = 10.0

var _phase: int = 0
var _timer: float = 0.0
var _player_ref: Node2D = null
var _interaction_started: bool = false
var _has_reached_player: bool = false
var _search_timer: float = 0.0
var _search_active: bool = false


func create(character_: Character, anim_: String = "Talk", duration_: float = 3.0, timeout_: float = 10.0) -> FindPlayer:
	super._create(character_, character_.global_position)
	anim_self = anim_
	anim_duration = duration_
	search_timeout = timeout_
	return self


func open() -> void:
	super()
	_phase = 0
	_timer = 0.0
	_search_timer = search_timeout
	_search_active = false
	_interaction_started = false
	_has_reached_player = false

	if character:
		var players: Array = character.get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			_player_ref = players[0]
		else:
			var candidate: Player = character.get_tree().get_root().get_node_or_null("LevelVillage/Player")
			if candidate:
				_player_ref = candidate

	if not _player_ref:
		push_warning("[FindPlayer] Player not found.")
		_complete()
		return

	_go_to_player_last_known_position()


func update(delta: float) -> void:
	if not character or not _player_ref:
		_complete()
		return

	if _has_reached_player:
		if _phase == 2:
			_timer -= delta
			if _timer <= 0.0:
				_end_interaction()
		return
		
	if _search_active:
		_search_timer -= delta
		if _search_timer <= 0.0:
			print("[FindPlayer] Player not found within time limit after arriving, giving up.")
			_complete()
			return

	if _subaction:
		super(delta)

	if not _interaction_started and _player_in_detection_range():
		_interaction_started = true
		_phase = 1
		_start_interaction()


func _go_to_player_last_known_position() -> void:
	if _player_ref:
		var pos: Vector2 = _player_ref.global_position
		var player_agent = _player_ref.find_child("AnchoredAgentV2")
		_subaction = GoTo.new().create(character, pos, player_agent.actor_layer)
		_subaction.action_closed.connect(_on_reached_last_known_position)
		_subaction.open()
		

func _on_reached_last_known_position() -> void:
	if _search_active:
		return

	print("[FindPlayer] Reached last known player position. Starting search timer.")
	_search_active = true
	_search_timer = search_timeout

	if _subaction:
		_subaction.action_closed.disconnect(_on_reached_last_known_position)
		_subaction = null
	
func _player_in_detection_range() -> bool:
	return character.global_position.distance_to(_player_ref.global_position) <= detection_radius


func _start_interaction() -> void:
	if not _player_ref:
		_complete()
		return

	print("[FindPlayer] Player detected, approaching once...")

	var direction: Vector2 = (_player_ref.global_position - character.global_position).normalized()
	var stop_pos: Vector2 = _player_ref.global_position - direction * approach_distance

	if _subaction:
		_subaction.close()

	_subaction = GoTo.new().create(character, stop_pos)
	_subaction.action_closed.connect(_on_reached_player)
	_subaction.open()


func _on_reached_player() -> void:
	if _has_reached_player:
		return

	_has_reached_player = true
	_phase = 2
	_timer = anim_duration
	character.velocity = Vector2.ZERO
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play(anim_self)
	print("[FindPlayer] NPC reached player and started animation.")


func _end_interaction() -> void:
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")
	print("[FindPlayer] Interaction with player finished.")
	_complete()
