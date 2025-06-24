extends CharacterBody2D
class_name NPCActions

@export var nav_layer: NavigationLayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var npc_floor_level: float = 0

const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

@onready var action_controller: ActionController = $ActionController

func _ready() -> void:
	assert(action_controller, "NPCActions doesn't have ActionController asigned")
	_actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		action_controller.request_override(GoTo.new().create(self, get_global_mouse_position()).with_recall())
	print(action_controller.current_action)
	action_controller.update(delta)

func _actor_setup() -> void:
	# Need to wait for physics frame for npc_floor_level to get set for moving
	await get_tree().physics_frame
	action_controller.start()
