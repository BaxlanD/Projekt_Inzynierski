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
	var center: Vector2 = player_ref.global_position
	var radius_step : float = 8.0
	var placed: bool = false
	
	for r in range(0, int(drop_radius)+1, radius_step):
		for angle_deg in range(-90, 91, 30):
			var angle: float = deg_to_rad(angle_deg)
			var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * r
			if await place_item_in_world(pos, item, index):
				placed = true
				break
		if placed:
			break
	
	
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
		await get_tree().process_frame
		items.remove_at(index)
		emit_signal("inventory_updated", items)
		return true
	else:
		print("Collision: can't place item here.")
		return false
		
func add_item_data(item: Item) -> bool:
	return add_item(item)
			
