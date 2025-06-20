extends CharacterBody2D
class_name NPC

## Simlar to player - a lot of code dupe and everything with pathfinding
## is honestly kind of a mess - I will make it better one day for sure

## Suggestion for script structure - subject to change
## Signals

## Enums

## Public variables

@export var nav_layer: NavLayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var pickup_area: Area2D = $PickupArea
@onready var pickup_timer := Timer.new()
@onready var npc_inventory: Inventory = $Inventory

## Private variables
const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

var _direction: int = 0
var _snap: bool = false
var _npc_floor_level: float = 0
var _path: PackedVector2Array = []
var _path_point_count: int = 0
var _next: Vector2
var _should_transform_to_sword: bool = false

# Godot method overrides

func _ready() -> void:
	pickup_timer.wait_time = 1.0
	pickup_timer.one_shot = true
	pickup_timer.connect("timeout", Callable(self, "_on_pickup_timer_timeout"))
	add_child(pickup_timer)

func _physics_process(delta: float) -> void:
	_npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		_generate_navigation_path()
		
	if _path.is_empty():
		_handle_naviation_path_finished(delta)
		return
		
	_next = _path[_path_point_count]
	_check_next_reached()
	
	_handle_ramps_collision()
	_handle_alt_platfs_collision()
	_handle_movement(delta)
	_handle_animations()
	
# Public methods

# Private methods

func _generate_navigation_path() -> void:
	_path_point_count = 0
	_path = nav_layer.get_good_nav_path(Vector2(position.x, _npc_floor_level), get_global_mouse_position())
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
			if _should_transform_to_sword:
				_handle_dropoff()
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
		
	_try_pickup_item()

func _handle_animations() -> void:
	if !is_on_floor():
		animated_sprite_2d.play("Fall")
	elif animated_sprite_2d.animation == "Fall" and is_on_floor():
		animated_sprite_2d.play("Land")
	else:
		animated_sprite_2d.play("Walk")

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("Idle")

func _try_pickup_item() -> void:
	if npc_inventory.get_items().size() > 0:
		return
	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("items") and area is Item:
			var item := area as Item
			
			if item.origin_scene_path != "res://items/item.tscn":
				continue
				
			if npc_inventory.add_item(item):
				item.visible = false
				item.set_deferred("monitoring", false)
				item.set_deferred("collision_layer", 0)
				item.set_deferred("collision_mask", 0)
				_should_transform_to_sword = true
				if _should_transform_to_sword:
					_path.clear()
					pickup_timer.start()
					print("NPC will go to dropoff point in 1 second")
				break

func _on_pickup_timer_timeout() -> void:
	var item_data: Dictionary = npc_inventory.get_item(0)
	if item_data.is_empty():
		return
	var packed_scene : PackedScene = item_data.get("packed_scene", null)
	
	if packed_scene:
		var drop_target: Vector2 = item_data.get("dropoff_position", Vector2.ZERO)
		
		_path_point_count = 0
		_path = nav_layer.get_good_nav_path(Vector2(position.x, _npc_floor_level), drop_target)
		print("NPC goes to position: ", drop_target)

func _handle_dropoff() -> void:
	var item_data: Dictionary = npc_inventory.get_item(0)
	if item_data.is_empty():
		return

	npc_inventory.remove_item(0)

	await get_tree().create_timer(1.0).timeout
	var drop_position := global_position + Vector2(25, -10)

	var sword_scene := preload("res://items/item_sword.tscn")
	var sword_instance := sword_scene.instantiate() as Node2D
	
	var item_node := sword_instance.get_node_or_null("Item") as Item
	if item_node != null and item_node is Item:
		item_node.initialize()
	else:
		print("Could not find 'Item' node in sword scene")

	sword_instance.global_position = drop_position
	get_tree().current_scene.add_child(sword_instance)

	print("NPC dropped sword at: ", drop_position)

	_should_transform_to_sword = false
