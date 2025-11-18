extends Action
class_name NewGoTo

@export var where: Vector2
var _snap: bool
var _direction: int

func create(character_: NPCActions, where_: Vector2) -> NewGoTo:
	character = character_
	where = where_
	return self

func open() -> void:
	character.animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	character.navigation_agent.set_navigation_target(where)
	pass

func update(delta: float) -> void:
	super(delta)
	if character.navigation_agent.is_navigation_finished():
		_complete()
		return
	
	var next_link: Vector2 = character.navigation_agent.get_next_path_position()
	_handle_collisions(next_link)
	_handle_movement(next_link, delta)
	_handle_animations()
	
func close() -> void:
	character.animated_sprite_2d.animation_finished.disconnect(_on_animation_finished)
	character.animated_sprite_2d.play("Idle")
	super()

## Helper functions
func _handle_collisions(next: Vector2) -> void:
	_handle_ramps_collision(next)
	_handle_alt_platfs_collision(next)

func _handle_ramps_collision(next: Vector2) -> void:
	if (next.y < character.npc_floor_level) or character.ray_cast_2d.get_collision_normal() != Vector2.UP:
		# NPC COLLIDE WITH RAMPS
		character.set_collision_mask_value(2, true)
	else:
		# NPC DON'T COLLIDE WITH RAMPS
		character.set_collision_mask_value(2, false)

func _handle_alt_platfs_collision(next: Vector2) -> void:
	if (next.y > character.npc_floor_level):
		# NPC DON'T COLLIDE WITH PLATFS
		character.set_collision_mask_value(3, false)
		_snap = true
	else:
		# NPC COLLIDE WITH PLATFS
		character.set_collision_mask_value(3, true)

func _handle_movement(next: Vector2, delta: float) -> void:
	if (next.x > character.position.x):
		_direction = 1
		character.animated_sprite_2d.flip_h = false
	else:
		_direction = -1
		character.animated_sprite_2d.flip_h = true
	
	var final_speed: float = min((next-character.position).length()/ delta, character._SPEED)
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

func _on_animation_finished() -> void:
	character.animated_sprite_2d.play("Idle")
