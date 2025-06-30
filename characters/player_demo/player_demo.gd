extends CharacterBody2D
class_name Player
## There is a lot of code dupe between this and NPC so that's something
## that should be fixed, but besides that it's mostly cleaned up

## Suggestion for script structure - subject to change
## Signals

## Enums

## Public variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D


## Private variables
const _SPEED = 180.0
const _JUMP_VELOCITY = -250.0

var _direction: float = 0.0
var _snap: bool = false
var _exclusive_action: bool = false


## Godot method overrides
func _physics_process(delta: float) -> void:
	# Kind of shitty but left it in anyway as an example
	if _exclusive_action:
		return
	
	_handle_ramps_collision()
	_handle_alt_platfs_collision()
	_handle_movement(delta)
	_handle_animations()


## Public methods
func execute_exclusive_action(action: Callable) -> void:
	_exclusive_action = true
	await action.call()
	_exclusive_action = false


## Private methods
func _handle_ramps_collision() -> void:
	if Input.is_action_pressed("ui_up") or ray_cast_2d.get_collision_normal() != Vector2.UP:
		# COLLIDE WITH RAMPS
		set_collision_mask_value(2, true)
	else:
		# DON'T COLLIDE WITH RAMPS
		set_collision_mask_value(2, false)


func _handle_alt_platfs_collision() -> void:
	if Input.is_action_pressed("ui_down"):
		# DON'T COLLIDE WITH ALT-PLATFORMS
		set_collision_mask_value(3, false)
		_snap = true
	else:
		# COLLIDE WITH ALT-PLATFORMS
		set_collision_mask_value(3, true)


func _handle_movement(delta: float) -> void:
	## HANDLING MOVEMENT INPUT
	_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = _direction * _SPEED
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _JUMP_VELOCITY
	
	## APPLYING GRAVITY
	velocity += get_gravity() * delta
	
	## MOVE_AND_SLIDE
	move_and_slide()
	if _snap:
		_snap = false
		apply_floor_snap()


func _handle_animations() -> void:
	if _direction:
		if _direction > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	
	if animated_sprite_2d.animation == "Fall" and is_on_floor():
		# This shouldn't be in animations cuz it affects behavior but doesn't matter for now
		execute_exclusive_action(_handle_landing.bind())
		return
	
	if _direction:
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
	
	if not is_on_floor():
		if velocity.y > 0:
			animated_sprite_2d.play("Fall")
		else:
			animated_sprite_2d.play("Jump")


func _handle_landing() -> void:
	animated_sprite_2d.play("Land")
	await animated_sprite_2d.animation_finished


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("Idle")
	
func interact(mouse_position: Vector2) -> void:
	var max_range := 50.0
	if global_position.distance_to(mouse_position) > max_range:
		print("Too far to interact.")
		return

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results: Array = space_state.intersect_point(query)

	for hit: Dictionary in results:
		var target : Node2D = hit["collider"]
		if target is Field:
			print("Field found!")
			var field := target as Field
			if field.curr_state != Field.state.destroyed:
				field.set_state(Field.state.burning)
				print("Field set on fire!")
			return
		elif target is NPC:
			var npc := target as NPC
			var schedule : ScheduleNPC = npc.get_node_or_null("ScheduleNPC")
			if schedule:
				var action : Action = schedule.schedule[schedule.entry_index].action
				if action is ReactAtPointAction:
					var react := action as ReactAtPointAction
					react.comfort()
