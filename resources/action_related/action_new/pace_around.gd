extends GoToAnd
class_name PaceAround

signal request_pickup(item_position: Vector2)

@export_range(0.0, 200.0) var walk_distance_min: float = 20.0
@export_range(0.0, 200.0) var walk_distance_max: float = 70.0
@export_range(0.1, 5.0) var pause_duration_min: float = 0.1
@export_range(0.1, 5.0) var pause_duration_max: float = 1.5

var item_to_detect: String
var walk_distance: float
var pause_duration: float

var _direction := 1
var _start_position: Vector2
var _target_position: Vector2
var _pause_timer: float = 0.0
var _is_pausing: bool = false
var _interrupted := false

func create(character_: Character, item_to_detect_: String) -> PaceAround:
	character = character_
	item_to_detect = item_to_detect_
	return self

func open() -> void:
	_start_position = character.global_position
	_choose_new_target()
	_start_subaction_to_target()

func update(delta: float) -> void:
	_check_timeout()

	if _interrupted:
		return

	if _is_pausing:
		_pause_timer -= delta
		if _pause_timer <= 0.0:
			if _check_for_item_nearby():
				_interrupt_and_pickup()
				return
			_direction *= -1
			_choose_new_target()
			_start_subaction_to_target()
			_is_pausing = false
		return

	if _subaction:
		_subaction.update(delta)

func close() -> void:
	_cleanup()
	super()

func _on_subaction_closed() -> void:
	_subaction = null

	if _interrupted:
		_complete()
		return

	character.animated_sprite_2d.play("Idle")
	_is_pausing = true
	_pause_timer = pause_duration

func _choose_new_target() -> void:
	walk_distance = randf_range(walk_distance_min, walk_distance_max)
	pause_duration = randf_range(pause_duration_min, pause_duration_max)
	_target_position = _start_position + Vector2(_direction * walk_distance, 0)

func _start_subaction_to_target() -> void:
	if _subaction:
		_subaction.close()

	_subaction = GoTo.new().create(character, _target_position)
	_subaction.action_closed.connect(_on_subaction_closed)
	_subaction.open()
	character.animated_sprite_2d.play("Walk")

func _find_nearby_item() -> Item:
	var area := character.get_node_or_null("PickupArea")
	if not area:
		push_warning("PickupArea not found on character.")
		return null

	for area2d in area.get_overlapping_areas():
		if area2d is Item:
			var item := area2d as Item
			if item.get_display_name() == item_to_detect:
				return item
	return null

func _check_for_item_nearby() -> bool:
	return _find_nearby_item() != null

func _interrupt_and_pickup() -> void:
	_interrupted = true
	var item := _find_nearby_item()
	if item:
		character.animated_sprite_2d.play("Idle")
		emit_signal("request_pickup", item.global_position)
	_complete()

func _cleanup() -> void:
	character.velocity = Vector2.ZERO
	character.animated_sprite_2d.play("Idle")

func was_successful() -> bool:
	return _interrupted
