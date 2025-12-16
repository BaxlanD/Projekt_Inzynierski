extends Character
class_name Player
## There is a lot of code dupe between this and NPC so that's something
## that should be fixed, but besides that it's mostly cleaned up

## Suggestion for script structure - subject to change
## Signals

## Enums

## Public variables
#   @onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D # IN CHARACTER
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var inventory_ui: InventoryUI = $"../UI/InventoryUI"
#   @onready var anchored_agent: AnchoredAgentV2 = $AnchoredAgentV2 # IN CHARACTER

## Private variables
const _SPEED = 180.0
const _JUMP_VELOCITY = -250.0

var _direction: float = 0.0

## Godot method overrides

func _ready() -> void:
	anchored_agent.initialize(self)
	sequence_controller.start(self)
	
func _physics_process(delta: float) -> void:
	_display_only_current_player_layer()
	
	if !sequence_controller._started:
		return
	
	if Input.is_action_just_pressed("RMB"):
		anchored_agent.set_destination(get_global_mouse_position())
		sequence_controller.push_instant(Sequence.new().with_fleeting().from_actions([
			GoTo.new().create(self, get_global_mouse_position())
		]))
	
	## MAKE API FUNCTION FOR IT
	if !sequence_controller._action_sequencer._stack.is_empty():
		sequence_controller.update(delta)
		return
	
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if inventory_ui and inventory_ui.is_open:

		velocity = Vector2.ZERO
		_direction = 0.0

		animated_sprite_2d.play("Idle")
		return
	
	if direction:
		anchored_agent.move_via_input(self, delta, direction)
		animated_sprite_2d.play("Run")
	else:
		anchored_agent.move_via_navigation(self, delta)
		animated_sprite_2d.play("Idle")
	_set_sprite_flip(direction.x)
	

## Public methods	
func get_inventory() -> Inventory:
	return get_node("Inventory") as Inventory

## Private methods

func _handle_animations() -> void:
	if _direction:
		if _direction > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	
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
	
func _display_only_current_player_layer() -> void:
	var current_level: Node2D = anchored_agent.navigator.get_child(anchored_agent.actor_layer)
	for lvl: Node2D in anchored_agent.navigator.get_children():
		lvl.modulate.a = 0.5
	current_level.modulate.a = 1
