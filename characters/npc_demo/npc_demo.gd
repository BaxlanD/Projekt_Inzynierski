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

## Private variables
const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

var _direction: int = 0
var _snap: bool = false

var _npc_floor_level: float = 0
var _path: PackedVector2Array = []
var _path_point_count: int = 0
var _next: Vector2

## Action-related
@onready var schedule_npc: ScheduleNPC = $ScheduleNPC
var action: Action

# Godot method overrides
func _ready() -> void:
	_actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
	_npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		print("[Overriding] Forced Action Override -> Setting Prioritized Action")
		if action:
			action.cancel()
		action = StandAtPointAction.new().create(self, Action.anchor.OVERRIDE, get_global_mouse_position(), 0.8)
		action.action_finished.connect(_on_action_finished)
	
	if action:
		action.update(delta)
		return

# Public methods

# Private methods
func _actor_setup() -> void:
	await get_tree().physics_frame
	schedule_npc.new_shedule_entry_started.connect(_on_schedule_entry_finished)
	schedule_npc.start_schedule()
	# At the start immidiately receive first new_schedule_entry_started signal

func _on_schedule_entry_finished() -> void:
	if action == null:
		action = schedule_npc.get_current_action()
		action.action_finished.connect(_on_action_finished)
		print("[Signal] Schedule Entry Finished -> Setting new (Prior Action Finished)")
	elif action.type == Action.anchor.SCHEDULE:
		action.cancel()
		action = schedule_npc.get_current_action()
		action.action_finished.connect(_on_action_finished)
		print("[Signal] Schedule Entry Finished -> Setting new (Prior Action Interupted)")
	else:
		print("[Signal] Schedule Entry Finished -> Postponed due to active interupt")

func _on_action_finished() -> void:
	if action.type == Action.anchor.OVERRIDE:
		action = schedule_npc.get_current_action()
		action.action_finished.connect(_on_action_finished)
		print("[Signal] Action Finished {OVERRIDE} -> Defaulting to Schedule")
	else:
		action = null
		print("[Signal] Action Finished {SCHEDULE} -> Afking - Scheduled action ended before earlier than anticipated")

# Move to action probably
func _generate_navigation_path(target: Vector2) -> void:
	_path_point_count = 0
	_path = nav_layer.get_good_nav_path(Vector2(position.x, _npc_floor_level), target)
	queue_redraw()

func _handle_naviation_path_finished(delta: float) -> void:
	_direction = 0
	velocity.x = 0
	velocity += get_gravity() * delta
	move_and_slide()
	animated_sprite_2d.play("Idle")

func _check_next_reached() -> void:
	# WARNING: This is quite shitty, make it less bootlegy later pls - me
	if abs(_next.x - position.x) <= 1:
		_path_point_count += 1
		if _path_point_count == _path.size():
			_path_point_count = 0
			_path.clear()
		else:
			_next = _path[_path_point_count]

func _handle_ramps_collision() -> void:
	if (_next.y < _npc_floor_level) or ray_cast_2d.get_collision_normal() != Vector2.UP:
		# NPC COLLIDE WITH RAMPS
		set_collision_mask_value(2, true)
	else:
		# NPC DON'T COLLIDE WITH RAMPS
		set_collision_mask_value(2, false)

func _handle_alt_platfs_collision() -> void:
	if (_next.y > _npc_floor_level):
		# NPC DON'T COLLIDE WITH PLATFS
		set_collision_mask_value(3, false)
		_snap = true
	else:
		# NPC COLLIDE WITH PLATFS
		set_collision_mask_value(3, true)

func _handle_movement(delta: float) -> void:
	if (_next.x > position.x):
		# POINT IS TO THE RIGHT
		_direction = 1
		animated_sprite_2d.flip_h = false
	else:
		# POINT IS TO THE LEFT
		_direction = -1
		animated_sprite_2d.flip_h = true
	
	var final_speed: float = min((_next-position).length()/ delta, _SPEED)
	velocity.x = _direction * final_speed
	velocity += get_gravity() * delta
	move_and_slide()
	
	if _snap:
		_snap = false
		apply_floor_snap()

func _handle_animations() -> void:
	if !is_on_floor():
		animated_sprite_2d.play("Fall")
	elif animated_sprite_2d.animation == "Fall" and is_on_floor():
		animated_sprite_2d.play("Land")
	else:
		animated_sprite_2d.play("Walk")

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("Idle")
