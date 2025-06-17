extends Control
class_name InventoryUI

var items : Array[Dictionary] = []
var item_icon := preload("res://assets/icon.svg")

var selected_item_index : int = -1
var is_placing_item := false
var item_to_place := {}
var item_index_to_remove := -1
var player_ref: Node2D = null 
const DROP_RADIUS := 50.0

@onready var popup : PopupPanel = $ItemPopupPanel
@onready var use_button : Button = popup.get_node("VBoxContainer/Use")
@onready var drop_button : Button = popup.get_node("VBoxContainer/Drop")

var item_display_names: Dictionary = {
	"res://items/item.tscn": "Item",
	"res://items/item_sword.tscn": "Sword"
}

var item_icons: Dictionary = {
	"res://items/item.tscn": preload("res://assets/icon.svg"),
	"res://items/item_sword.tscn": preload("res://assets/sword_icon.jpg")
}

func _ready() -> void:
	player_ref = get_tree().current_scene.get_node("Player")
	
	use_button.pressed.connect(_on_use_button_pressed)
	drop_button.pressed.connect(_on_drop_button_pressed)

func add_item(item: Item) -> bool:
	if items.size() >= 4:
		show_inventory_full_message()
		return false
		
	var packed_scene: PackedScene = load(item.origin_scene_path)
	if packed_scene == null:
		print("Error loading packed scene from path: ", item.origin_scene_path)
		return false
		
	var item_data := {
		"packed_scene": load(item.origin_scene_path),
		"display_name": item.get_display_name(),
		"icon": item.get_icon()
	}
		
	items.append(item_data)
	update_inventory_ui()
	return true
	
func show_inventory_full_message() -> void:
	print("Inventory full!")
	
func update_inventory_ui() -> void:
	var panel: GridContainer = get_node("Panel/GridContainer") as GridContainer
	for i in range(panel.get_child_count()):
		var slot: Button = panel.get_child(i) as Button
		var cont: VBoxContainer = slot.get_node("VBoxContainer") as VBoxContainer
		var icon: TextureRect = cont.get_node("TextureRect") as TextureRect
		var label: Label = cont.get_node("Label") as Label

		if slot.is_connected("pressed", Callable(self, "_on_item_pressed")):
			slot.pressed.disconnect(Callable(self, "_on_item_pressed"))

		if not slot.pressed.is_connected(Callable(self, "_on_item_pressed").bind(i)):
			slot.pressed.connect(Callable(self, "_on_item_pressed").bind(i))

		if i < items.size():
			var item_data: Dictionary = items[i]
			icon.texture = item_data["icon"]
			icon.expand = true
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			label.text = item_data["display_name"]
			slot.disabled = false
		else:
			icon.texture = null
			label.text = ""
			slot.disabled = true
			
func _on_item_pressed(index: int) -> void:
	if index >= items.size():
		return
	selected_item_index = index

	var panel: GridContainer = get_node("Panel/GridContainer") as GridContainer
	var slot: Button = panel.get_child(index) as Button

	var global_pos: Vector2 = slot.get_global_position()
	popup.set_position(global_pos + Vector2(60, 0)) 
	popup.popup()
		
func _on_use_button_pressed() -> void:
	popup.hide()
	if selected_item_index < 0 or selected_item_index >= items.size():
		return

	var item_data: Dictionary = items[selected_item_index]
	var packed_scene: PackedScene = item_data.get("packed_scene", null)
	if packed_scene == null:
		print("No packed scene")
		return

	var item_instance: Node = packed_scene.instantiate()
	var item_script_node: Item = item_instance.get_node_or_null("Item")

	if item_script_node != null and item_script_node is Item:
		item_script_node.use()
	else:
		print("Could not find Item node in scene: ", item_instance.name)

func _on_drop_button_pressed() -> void:
	popup.hide()
	print("Dropping item: ", selected_item_index)
	if selected_item_index >= 0 and selected_item_index < items.size():
		item_to_place = items[selected_item_index]
		item_index_to_remove = selected_item_index
		is_placing_item = true
		
func place_item_in_world(position_a: Vector2) -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

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
		var packed_scene: PackedScene = item_to_place.get("packed_scene", null)
		if not packed_scene:
			print("Error: No packed_scene in item_to_place")
			return

		var item_instance: Node2D = packed_scene.instantiate()
		if item_instance is Node2D:
			item_instance.global_position = position_a
			get_tree().current_scene.add_child(item_instance)
			print("Player placed item at:", item_instance.global_position)
		else:
			print("Error: Item is not Node2D")

		items.remove_at(item_index_to_remove)
		update_inventory_ui()
		is_placing_item = false
		item_to_place = {}
		item_index_to_remove = -1
	else:
		print("Collision: can't place item here.")

	
