extends Control

var items : Array[String] = []
var item_icon := preload("res://assets/icon.svg")

var is_placing_item := false
var item_to_place := ""
var item_index_to_remove := -1
var player_ref: Node2D = null 
const DROP_RADIUS := 50.0

func _ready():
	player_ref = get_tree().current_scene.get_node("Player")

func add_item(item_name: String) -> bool:
	if items.size() >= 4:
		show_inventory_full_message()
		return false
		
	items.append(item_name)
	update_inventory_ui()
	return true
	
func show_inventory_full_message() -> void:
	print("Inventory full!")
	
func update_inventory_ui() -> void:
	var panel = get_node("Panel/GridContainer") as GridContainer
	for i in range(panel.get_child_count()):
		var slot = panel.get_child(i) as Button
		var cont = slot.get_node("VBoxContainer") as VBoxContainer
		var icon = cont.get_node("TextureRect") as TextureRect
		var label = cont.get_node("Label") as Label

		if slot.is_connected("pressed", Callable(self, "_on_item_pressed")):
			slot.pressed.disconnect(Callable(self, "_on_item_pressed"))

		if not slot.pressed.is_connected(Callable(self, "_on_item_pressed").bind(i)):
			slot.pressed.connect(Callable(self, "_on_item_pressed").bind(i))

		if i < items.size():
			icon.texture = item_icon
			icon.expand = true
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			label.text = items[i]
			slot.disabled = false
		else:
			icon.texture = null
			label.text = ""
			slot.disabled = true
			
func _on_item_pressed(index: int) -> void:
	print("Item chosen. self =", self)
	if index < items.size():
		item_to_place = items[index]
		item_index_to_remove = index
		is_placing_item = true
		
func place_item_in_world(position: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state

	var shape := CircleShape2D.new()
	shape.radius = 8.0

	var transform := Transform2D.IDENTITY
	transform.origin = position

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_shape(query, 1)

	if result.is_empty():
		var scene = preload("res://levels/item.tscn")
		var item_instance = scene.instantiate()
		item_instance.global_position = position
		get_tree().current_scene.add_child(item_instance)
		
		#if item_instance is RigidBody2D:
			#item_instance.apply_impulse(Vector2(randf_range(-50, 50), -100))

		items.remove_at(item_index_to_remove)
		update_inventory_ui()

		is_placing_item = false
		item_to_place = ""
		item_index_to_remove = -1
	else:
		print("Collision Error!")
	
