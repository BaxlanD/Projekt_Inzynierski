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

## Private variables
const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

## Action-related
@onready var schedule_npc: ScheduleNPC = $ScheduleNPC
var action: ActionD = ActionD.new()

var _should_transform_to_sword: bool = false

# Godot method overrides
func _ready() -> void:
	pickup_timer.wait_time = 1.0
	pickup_timer.one_shot = true
	pickup_timer.connect("timeout", Callable(self, "_on_pickup_timer_timeout"))
	add_child(pickup_timer)
	_actor_setup.call_deferred()

func _physics_process(delta: float) -> void:
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("RMB"):
		set_action(AnimateAtPointAction.new().create(self, ActionD.anchor.OVERRIDE, get_global_mouse_position(), "Death"))
	
	_try_pickup_item()
	_handle_dropoff()
	if action:
		action.update(delta)
		return

# Public methods
func set_action(new_action: ActionD, cancel: bool = true) -> void:
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
	if action.type != ActionD.anchor.OVERRIDE:
		set_action(schedule_npc.get_current_action())

func _on_action_finished() -> void:
	if action.type == ActionD.anchor.SCHEDULE:
		set_action(ActionD.new(), false) # Don't call cancel - action has finished
	else:
		set_action(schedule_npc.get_current_action(), false) # Don't call cancel - action has finished

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
					#_path.clear()
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
		
		#_path_point_count = 0
		#_path = nav_layer.get_good_nav_path(Vector2(position.x, _npc_floor_level), drop_target)
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
