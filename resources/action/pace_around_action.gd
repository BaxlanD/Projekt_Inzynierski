extends Action
class_name PaceAroundAction

signal request_pickup(item_position: Vector2)

@export_range(0.0, 200.0) var walk_distance_min: float = 20.0
@export_range(0.0, 200.0) var walk_distance_max: float = 70.0
@export_range(0.1, 5) var pause_duration_min: float = 0.1
@export_range(0.1, 5) var pause_duration_max: float = 1.5

var walk_distance: float
var pause_duration: float
var item_to_detect: String

var _direction := 1
var _start_position: Vector2
var _target_position: Vector2
var _time_elapsed: float = 0.0
var _is_pausing: bool = false
var _pause_timer: float = 0.0
var _interrupted := false

func create(character_: CharacterBody2D, item_to_detect_: String) -> PaceAroundAction:
	character = character_
	item_to_detect = item_to_detect_
	_start()
	print("PaceAroundAction created with item_to_detect =", item_to_detect)
	return self

func copy() -> PaceAroundAction:
	return PaceAroundAction.new().create(character, item_to_detect)

func _start() -> void:
	_start_position = character.global_position
	_set_new_target()
	character.animated_sprite_2d.play("Walk")

func update(delta: float) -> void:
	if _is_pausing:
		_pause_timer -= delta
		if _pause_timer <= 0:
			if _check_for_item_nearby():
				_interrupt_and_pickup()
				return
			_is_pausing = false
			_direction *= -1
			_set_new_target()
			character.animated_sprite_2d.play("Walk")
		return

	_time_elapsed += delta
	_move_towards_target(delta)

func _set_new_target() -> void:
	walk_distance = randf_range(walk_distance_min, walk_distance_max)
	pause_duration = randf_range(pause_duration_min, pause_duration_max)
	_target_position = _start_position + Vector2(_direction * walk_distance, 0)

func _move_towards_target(delta: float) -> void:
	var distance: float = _target_position.x - character.global_position.x
	var step: float = sign(distance) * character._SPEED * delta

	if abs(step) >= abs(distance):
		character.global_position.x = _target_position.x
		character.velocity = Vector2.ZERO
		character.animated_sprite_2d.play("Idle")
		_is_pausing = true
		_pause_timer = pause_duration
	else:
		character.velocity.x = step / delta
		character.move_and_slide()
		character.animated_sprite_2d.flip_h = step < 0
		
func _find_nearby_item() -> Item:
	print("Looking for item: " + item_to_detect)
	var area: Area2D = character.get_node_or_null("SightArea")
	if not area:
		push_warning("SightArea not found.")
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
		emit_signal("request_pickup", item.global_position)
		
func _on_pickup_finished() -> void:
	action_finished.emit()

func was_successful() -> bool:
	return _interrupted

func cancel() -> void:
	_cleanup()

func _cleanup() -> void:
	character.velocity = Vector2.ZERO
	character.animated_sprite_2d.play("Idle")

func _finish() -> void:
	_cleanup()
	action_finished.emit()
