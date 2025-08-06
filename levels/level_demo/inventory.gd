extends Node
class_name Inventory

signal inventory_updated(items: Array)

@export var max_items: int = 4
var items: Array[Item] = []
@onready var player_ref: Node2D = $".."
var drop_radius := 50.0

var is_placing_item := false
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
	item_to_place = items[index]
	item_index_to_remove = index
	is_placing_item = true
	print("Ready to place item in world...")
	
func try_place_selected_item(pos: Vector2) -> void:
	if not is_placing_item:
		return

	var space_state : PhysicsDirectSpaceState2D = (get_tree().current_scene as Node2D).get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result: Array[Dictionary] = space_state.intersect_point(query, 1)

	for r in result:
		if r.has("collider") and r["collider"] is NPC:
			var npc: NPC = r["collider"]
			print(npc)
			if npc.npc_inventory.add_item_data(item_to_place):
				print("Item given to NPC")
				items.remove_at(item_index_to_remove)
				emit_signal("inventory_updated", items)
			else:
				print("NPC inventory full")
			_reset_placement_state()
			return

	var success := place_item_in_world(pos, item_to_place, item_index_to_remove)
	if success:
		_reset_placement_state()
		
func _reset_placement_state() -> void:
	is_placing_item = false
	item_to_place = null
	item_index_to_remove = -1
	
func place_item_in_world(position: Vector2, item: Item, index: int) -> bool:
	var space_state: PhysicsDirectSpaceState2D = (get_tree().current_scene as Node2D).get_world_2d().direct_space_state

	var shape := CircleShape2D.new()
	shape.radius = 8.0

	var transform := Transform2D.IDENTITY
	transform.origin = position

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result: Array[Dictionary] = space_state.intersect_shape(query, 1)
	
	if result.is_empty():
		item.global_position = transform.origin
		get_tree().current_scene.add_child(item)
		items.remove_at(index)
		emit_signal("inventory_updated", items)
		return true
	else:
		print("Collision: can't place item here.")
		return false
		
func add_item_data(item: Item) -> bool:
	return add_item(item)
			
