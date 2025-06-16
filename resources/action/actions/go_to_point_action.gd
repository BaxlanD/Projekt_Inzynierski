extends Action
class_name GoToPointAction

@export var target: Vector2

# Public methods
func create(character_: CharacterBody2D, type_: anchor, target_: Vector2) -> GoToPointAction:
	character = character_
	type = type_
	target = target_
	_start()
	return self

func copy() -> GoToPointAction:
	return GoToPointAction.new().create(character, type, target)

func update(delta: float) -> void:
	if character._path.is_empty():
		character._handle_naviation_path_finished(delta)
		_finish()
		return
	
	character._next = character._path[character._path_point_count]
	character._check_next_reached()
	character._handle_ramps_collision()
	character._handle_alt_platfs_collision()
	character._handle_movement(delta)
	character._handle_animations()

func cancel() -> void:
	_cleanup()

# Private methods
func _start() -> void:
	character._generate_navigation_path(target)

func _cleanup() -> void:
	character.animated_sprite_2d.play("Idle")

func _finish() -> void:
	_cleanup()
	action_finished.emit()
