extends CharacterBody2D
class_name NPCActions

@export var navigation_layer: NavigationLayer
@export var anchored_agent: AnchoredAgent

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var npc_floor_level: float = 0

const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

@onready var sequence_controller: SequenceController = $SequenceController

func _ready() -> void:
	assert(sequence_controller, "NPCActions doesn't have SequenceController asigned")
	anchored_agent.initialize(self)
	sequence_controller.start(self)

func _physics_process(delta: float) -> void:
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		sequence_controller.push_instant(Sequence.new().with_fleeting().from_actions([
			PlayAnim.new().create(self, get_global_mouse_position(), "Death")
		]))
	
	sequence_controller.update(delta)
