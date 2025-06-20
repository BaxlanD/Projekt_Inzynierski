extends Control
class_name InventoryUI

@onready var inventory_node: Inventory = $"../../Player/Inventory"

var selected_item_index: int = -1

@onready var popup: PopupPanel = $ItemPopupPanel
@onready var use_button: Button = popup.get_node("VBoxContainer/Use")
@onready var drop_button: Button = popup.get_node("VBoxContainer/Drop")

func _ready() -> void:
	if inventory_node != null:
		inventory_node.inventory_updated.connect(_on_inventory_updated)

	use_button.pressed.connect(_on_use_button_pressed)
	drop_button.pressed.connect(_on_drop_button_pressed)

	update_inventory_ui()
	
func _on_inventory_updated(_new_items: Array) -> void:
	update_inventory_ui()

func update_inventory_ui() -> void:
	var items: Array[Dictionary] = inventory_node.get_items()
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
	var items: Array[Dictionary] = inventory_node.get_items()
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
	if selected_item_index < 0:
		return
	inventory_node.use_item(selected_item_index)

func _on_drop_button_pressed() -> void:
	popup.hide()
	if selected_item_index < 0:
		return
	inventory_node.drop_item(selected_item_index)
