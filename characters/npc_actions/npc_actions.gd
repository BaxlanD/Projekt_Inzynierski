extends CharacterBody2D
class_name NPCActions

@export var navigation_layer: NavigationLayer
@export var navigation_agent: NavigationAgent

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var npc_floor_level: float = 0

const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

@onready var sequence_controller: SequenceController = $SequenceController

func _ready() -> void:
	assert(sequence_controller, "NPCActions doesn't have SequenceController asigned")
	_actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		sequence_controller.push_instant(Sequence.new().with_fleeting().from_actions([
			#PlayAnim.new().create(self, get_global_mouse_position(), "Death")
			NewGoTo.new().create(self, get_global_mouse_position())
		]))
	
	sequence_controller.update(delta)

func _actor_setup() -> void:
	# Need to wait for physics frame for npc_floor_level to get set for moving
	await get_tree().physics_frame
	navigation_agent.initialize(self, navigation_layer)
	sequence_controller.start(self)
