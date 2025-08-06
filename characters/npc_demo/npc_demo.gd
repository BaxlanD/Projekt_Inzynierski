extends CharacterBody2D
class_name NPC

## Simlar to player - a lot of code dupe and everything with pathfinding
## is honestly kind of a mess - I will make it better one day for sure

## Suggestion for script structure - subject to change
## Signals

## Enums

## Public variables
@export var nav_layer: NavigationLayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var npc_floor_level: float = 0

@onready var pickup_area: Area2D = $PickupArea
@onready var pickup_timer := Timer.new()
@onready var npc_inventory: Inventory = $Inventory
@onready var bad_day: int = 0
@onready var interactable: Interactable = $Interactable


## Private variables
const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

## Action-related
@onready var schedule_npc: ScheduleNPC = $ScheduleNPC
var action: Action = Action.new()

# Godot method overrides
func _ready() -> void:
	pickup_timer.wait_time = 1.0
	pickup_timer.one_shot = true
	pickup_timer.connect("timeout", Callable(self, "_on_pickup_timer_timeout"))
	add_child(pickup_timer)
	_actor_setup.call_deferred()
	interactable.interact = _on_interact

func _physics_process(delta: float) -> void:
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	#if Input.is_action_just_pressed("RMB"):
		#set_action(AnimateAtPointAction.new().create(self, Action.anchor.OVERRIDE, get_global_mouse_position(), "Death"))
	
	if action:
		action.update(delta)
		return

# Public methods
func set_action(new_action: Action, cancel: bool = true) -> void:
	if cancel:
		action.cancel()
	action = new_action
	action.action_finished.connect(_on_action_finished)

# Private methods
func _actor_setup() -> void:
	await get_tree().physics_frame
	schedule_npc.new_shedule_entry_started.connect(_on_schedule_entry_finished)
	schedule_npc.start_schedule()

func _on_schedule_entry_finished() -> void:
	if action.type != Action.anchor.OVERRIDE:
		set_action(schedule_npc.get_current_action())

func _on_action_finished() -> void:
	if action.type == Action.anchor.SCHEDULE:
		set_action(Action.new(), false) # Don't call cancel - action has finished
	else:
		set_action(schedule_npc.get_current_action(), false) # Don't call cancel - action has finished
		
func _on_interact() -> void:
	var schedule: ScheduleNPC = get_node_or_null("ScheduleNPC")
	if schedule:
		var action_to_check: ReactAtPointAction = schedule.schedule[schedule.entry_index].action
		if action_to_check is ReactAtPointAction:
			action_to_check.comfort()
