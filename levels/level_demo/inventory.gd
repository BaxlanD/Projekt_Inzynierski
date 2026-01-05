extends Node
class_name Inventory

signal inventory_updated(items: Array)

@export var max_items: int = 4
var items: Array[Item] = []
@onready var player_ref: Node2D = $".."
var drop_radius : float = 32.0

var item_to_place : Item = null
var item_index_to_remove := -1

func add_item(item: Item) -> bool:
	if items.size() >= max_items:
		print("Inventory full!")
		return false
		
	items.append(item)
	emit_signal("inventory_updated", items)
	return true

func get_items() -> Array[Item]:
	return items
		

func get_item(index: int) -> Item:
	if index >= 0 and index < items.size():
		return items[index]
	return null
	
func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items.remove_at(index)
		emit_signal("inventory_updated", items)
	
func drop_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return

	var item: Item = items[index]
	var center: Vector2 = (get_parent() as Node2D).global_position
	var offset := 10.0

	var pos_right := center + Vector2(offset, -15)
	if await place_item_in_world(pos_right, item, index):
		return

	var pos_left := center + Vector2(-offset, -15)
	await place_item_in_world(pos_left, item, index)
	
	
func place_item_in_world(position: Vector2, item: Item, index: int) -> bool:
	var space_state: PhysicsDirectSpaceState2D = (
		(get_tree().current_scene as Node2D).get_world_2d().direct_space_state
	)

	var shape := CircleShape2D.new()
	shape.radius = 8.0

	var transform := Transform2D.IDENTITY
	transform.origin = position

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform

	query.collision_mask = (1 << 0) | (1 << 1) | (1 << 2)

	query.collide_with_bodies = true
	query.collide_with_areas = true

	var result: Array[Dictionary] = space_state.intersect_shape(query, 1)
	
	if result.is_empty():
		var layer := _get_owner_actor_layer()
		if layer != -1:
			item.actor_layer = layer
		
		item.global_position = transform.origin
		
		var items_node := _get_level_items_node()
		if items_node:
			items_node.add_child(item)
		else:
			get_tree().current_scene.add_child(item)
		
		await get_tree().process_frame
		items.remove_at(index)
		emit_signal("inventory_updated", items)
		return true
	else:
		print("Collision: can't place item here.")
		return false
		
func add_item_data(item: Item) -> bool:
	return add_item(item)
	
func _get_owner_actor_layer() -> int:
	var item_owner := get_parent()
	if not item_owner:
		return -1
		
	for child in item_owner.get_children():
		if child is AnchoredAgentV2:
			@warning_ignore("unsafe_property_access")
			return child.actor_layer
			
	if "actor_layer" in item_owner:
		@warning_ignore("unsafe_property_access")
		return item_owner.actor_layer
		
	return -1
	
func _get_level_items_node() -> Node:
	var level := get_tree().current_scene as Level
	if not level:
		return null
	return level.items
			
