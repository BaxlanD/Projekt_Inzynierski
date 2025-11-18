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
@onready var inventory_ui: InventoryUI = $"../UI/InventoryUI"
@onready var anchored_agent: AnchoredAgent = $AnchoredAgent


## Private variables
const _SPEED = 180.0
const _JUMP_VELOCITY = -250.0

var _direction: float = 0.0
var _snap: bool = false
var _exclusive_action: bool = false


## Godot method overrides

func _ready() -> void:
	anchored_agent.initialize(self)

	
func _physics_process(delta: float) -> void:
	# Kind of shitty but left it in anyway as an example
	if _exclusive_action:
		return
		
	if inventory_ui and inventory_ui.is_open:
		_direction = 0.0
		velocity.x = move_toward(velocity.x, 0.0, 2000.0 * delta)
		velocity += get_gravity() * delta
		move_and_slide()
		_handle_animations()
		return
	
	#_handle_ramps_collision()
	#_handle_alt_platfs_collision()
	#_handle_movement(delta)
	#_handle_animations()
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		anchored_agent.move_via_input(self, delta, direction)
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
	_set_sprite_flip(direction.x)
	

## Public methods
func execute_exclusive_action(action: Callable) -> void:
	_exclusive_action = true
	await action.call()
	_exclusive_action = false
	

func get_inventory() -> Inventory:
	return get_node("Inventory") as Inventory

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
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
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

func _set_sprite_flip(facing: float) -> void:
	if facing > 0:
		animated_sprite_2d.flip_h = false
	if facing < 0:
		animated_sprite_2d.flip_h = true

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("Idle")
	
