extends Action
class_name GoTo

@export var where: Vector2
@export var speed_multiplier: float = 1.0

var _path: PackedVector2Array = []
var _path_point_count: int = 0
var _next: Vector2
var _direction: int = 0
var _snap: bool = false

func create(character_: NPCActions, where_: Vector2) -> GoTo:
	character = character_
	where = where_
	return self

func open() -> void:
	_generate_navigation_path(where)

func update(delta: float) -> void:
	super(delta)
	if _path.is_empty():
		_handle_naviation_path_finished(delta)
		_complete() ## Mark action as complete, then close()
		return
	
	_next = _path[_path_point_count]
	_check_next_reached()
	_handle_ramps_collision()
	_handle_alt_platfs_collision()
	_handle_movement(delta)
	_handle_animations()

func close() -> void:
	action_closed.emit()

# HELPER METHODS
func _generate_navigation_path(navigation_target: Vector2) -> void:
	_path_point_count = 0
	_path = character.nav_layer.get_good_nav_path(Vector2(character.position.x, character.npc_floor_level), navigation_target)
	character.queue_redraw()

func _handle_naviation_path_finished(delta: float) -> void:
	_direction = 0
	character.velocity.x = 0
	character.velocity += character.get_gravity() * delta
	character.move_and_slide()
	character.animated_sprite_2d.play("Idle")

func _check_next_reached() -> void:
	# WARNING: This is quite shitty, make it less bootlegy later pls - me
	if abs(_next.x - character.position.x) <= 1:
		_path_point_count += 1
		if _path_point_count == _path.size():
			_path_point_count = 0
			_path.clear()
		else:
			_next = _path[_path_point_count]

func _handle_ramps_collision() -> void:
	if (_next.y < character.npc_floor_level) or character.ray_cast_2d.get_collision_normal() != Vector2.UP:
		# NPC COLLIDE WITH RAMPS
		character.set_collision_mask_value(2, true)
	else:
		# NPC DON'T COLLIDE WITH RAMPS
		character.set_collision_mask_value(2, false)

func _handle_alt_platfs_collision() -> void:
	if (_next.y > character.npc_floor_level):
		# NPC DON'T COLLIDE WITH PLATFS
		character.set_collision_mask_value(3, false)
		_snap = true
	else:
		# NPC COLLIDE WITH PLATFS
		character.set_collision_mask_value(3, true)

func _handle_movement(delta: float) -> void:
	if (_next.x > character.position.x):
		# POINT IS TO THE RIGHT
		_direction = 1
		character.animated_sprite_2d.flip_h = false
	else:
		# POINT IS TO THE LEFT
		_direction = -1
		character.animated_sprite_2d.flip_h = true
	
	var final_speed: float = min((_next-character.position).length()/ delta, character._SPEED * speed_multiplier)
	character.velocity.x = _direction * final_speed
	character.velocity += character.get_gravity() * delta
	character.move_and_slide()
	
	if _snap:
		_snap = false
		character.apply_floor_snap()

func _handle_animations() -> void:
	if !character.is_on_floor():
		character.animated_sprite_2d.play("Fall")
	elif character.animated_sprite_2d.animation == "Fall" and character.is_on_floor():
		character.animated_sprite_2d.play("Land")
	else:
		character.animated_sprite_2d.play("Walk")

func _on_animated_sprite_2d_animation_finished() -> void:
	character.animated_sprite_2d.play("Idle")
