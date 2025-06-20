extends Node
class_name Inventory

signal inventory_updated(items: Array)

@export var max_items: int = 4
var items: Array[Dictionary] = []
@onready var player_ref: Node2D = $".."
var drop_radius := 50.0

var is_placing_item := false
var item_to_place := {}
var item_index_to_remove := -1

func add_item(item: Item) -> bool:
	if items.size() >= max_items:
		print("Inventory full!")
		return false

	var packed_scene: PackedScene = load(item.origin_scene_path)
	if packed_scene == null:
		print("Error loading packed scene from path: ", item.origin_scene_path)
		return false

	var item_data := {
		"packed_scene": packed_scene,
		"display_name": item.get_display_name(),
		"icon": item.get_icon(),
		"dropoff_position": item.get_dropoff_position()
	}

	items.append(item_data)
	emit_signal("inventory_updated", items)
	return true

func get_items() -> Array[Dictionary]:
	return items

func use_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return

	var item_data: Dictionary = items[index]
	var packed_scene: PackedScene = item_data.get("packed_scene", null)
	if packed_scene == null:
		print("No packed scene in inventory")
		return

	var item_instance: Node = packed_scene.instantiate()
	var item_script_node: Item = item_instance.get_node_or_null("Item")
	if item_script_node != null and item_script_node is Item:
		item_script_node.use()
	else:
		print("Could not find Item script in: ", item_instance.name)

func get_item(index: int) -> Dictionary:
	if index >= 0 and index < items.size():
		return items[index]
	return {}
	
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
	if is_placing_item:
		var success := place_item_in_world(pos, item_to_place, item_index_to_remove)
		if success:
			is_placing_item = false
			item_to_place = {}
			item_index_to_remove = -1
	
func place_item_in_world(position_a: Vector2, item_data: Dictionary, index: int) -> bool:
	var space_state: PhysicsDirectSpaceState2D = (get_tree().current_scene as Node2D).get_world_2d().direct_space_state

	var shape := CircleShape2D.new()
	shape.radius = 8.0

	var transform := Transform2D.IDENTITY
	transform.origin = position_a

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result: Array[Dictionary] = space_state.intersect_shape(query, 1)

	if result.is_empty():
		var packed_scene: PackedScene = item_data.get("packed_scene", null)
		if not packed_scene:
			print("Error: No packed_scene in item_data")
			return false

		var item_instance: Node2D = packed_scene.instantiate()
		if item_instance is Node2D:
			item_instance.global_position = transform.origin
			get_tree().current_scene.add_child(item_instance)
			print("Item placed at:", item_instance.global_position)
		else:
			print("Error: Instance is not Node2D")
			return false
		items.remove_at(index)
		emit_signal("inventory_updated", items)
		return true
	else:
		print("Collision: can't place item here.")
		return false
