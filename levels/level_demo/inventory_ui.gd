extends Control
class_name InventoryUI

@onready var inventory_node: Inventory = $"../../Player/Inventory"

var is_open: bool = false
var selected_item_index: int = 0
var in_popup: bool = false
var popup_option_index: int = 0

@onready var popup: PopupPanel = $ItemPopupPanel
@onready var drop_button: Button = popup.get_node("VBoxContainer/Drop")
@onready var close_button: Button = popup.get_node("VBoxContainer/Close")


func _ready() -> void:
	if inventory_node != null:
		inventory_node.inventory_updated.connect(_on_inventory_updated)
		
	drop_button.pressed.connect(_on_drop_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	selected_item_index = 0
	update_inventory_ui()
	highlight_selected()
	
func _on_inventory_updated(_new_items: Array) -> void:
	var count := inventory_node.get_items().size()
	if count == 0:
		selected_item_index = -1
	else:
		selected_item_index = clamp(selected_item_index, 0, count - 1)
	update_inventory_ui()
	highlight_selected()
	
func update_inventory_ui() -> void:
	var items: Array[Item] = inventory_node.get_items()
	var panel: GridContainer = get_node("InvPanel/GridContainer") as GridContainer
	for i in range(panel.get_child_count()):
		var slot: Button = panel.get_child(i) as Button
		var cont: VBoxContainer = slot.get_node("VBoxContainer") as VBoxContainer
		var icon: TextureRect = cont.get_node("TextureRect") as TextureRect
		var label: Label = cont.get_node("Label") as Label

		if i < items.size():
			var item: Item = items[i]
			icon.texture = item.get_icon()
			@warning_ignore("unsafe_property_access")
			icon.expand = true
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			label.text = item.get_display_name()
			slot.disabled = false
		else:
			icon.texture = null
			label.text = ""
			slot.disabled = true

func highlight_selected() -> void:
	var panel: GridContainer = get_node("InvPanel/GridContainer") as GridContainer
	var items_count := inventory_node.get_items().size()

	for i in range(panel.get_child_count()):
		var slot: Button = panel.get_child(i)
		var cont: VBoxContainer = slot.get_node("VBoxContainer") as VBoxContainer
		var icon: TextureRect = cont.get_node("TextureRect") as TextureRect
		
		slot.remove_theme_stylebox_override("normal")
		slot.remove_theme_color_override("font_color")
		icon.modulate = Color(1,1,1) 

	if items_count == 0 or selected_item_index < 0:
		selected_item_index = -1
		return

	selected_item_index = clamp(selected_item_index, 0, items_count - 1)

	var selected_slot: Button = panel.get_child(selected_item_index)
	var selected_cont: VBoxContainer = selected_slot.get_node("VBoxContainer") as VBoxContainer
	var selected_icon: TextureRect = selected_cont.get_node("TextureRect") as TextureRect

	selected_slot.add_theme_color_override("font_color", Color.YELLOW)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.5, 0.5, 0.2, 1)
	selected_slot.add_theme_stylebox_override("normal", stylebox)
	selected_icon.modulate = Color(1, 1, 0.5) 
			

func _open_item_popup(index: int) -> void:
	var items: Array[Item] = inventory_node.get_items()
	if index >= items.size():
		return
	selected_item_index = index
	in_popup = true
	popup_option_index = 0
	_update_popup_selection()
	await get_tree().process_frame
	
	var panel: GridContainer = get_node("InvPanel/GridContainer") as GridContainer
	var slot: Button = panel.get_child(index) as Button
	var global_pos: Vector2 = slot.get_global_position()
	popup.set_position(global_pos + Vector2(60, 0))
	popup.popup()
	
func _update_popup_selection() -> void:
	if popup_option_index == 0:
		drop_button.grab_focus()
	elif popup_option_index == 1:
		close_button.grab_focus()
			

func _on_drop_button_pressed() -> void:
	popup.hide()
	in_popup = false
	if selected_item_index < 0:
		return
	inventory_node.drop_item(selected_item_index)
		
func _on_close_button_pressed() -> void:
	popup.hide()
	in_popup = false
	

func _unhandled_input(event: InputEvent) -> void:
	if is_open:
		if event.is_action_pressed("ui_cancel"):
			if in_popup:
				popup.hide()
				in_popup = false
			return

		if in_popup:
			if event.is_action_pressed("ui_up"):
				popup_option_index = max(0, popup_option_index - 1)
				_update_popup_selection()
			elif event.is_action_pressed("ui_down"):
				popup_option_index = min(1, popup_option_index + 1)
				_update_popup_selection()
			elif event.is_action_pressed("interact"):
				if popup_option_index == 0:
					_on_drop_button_pressed()
				elif popup_option_index == 1:
					_on_close_button_pressed()
			return
			
		var items_count: int = inventory_node.get_items().size()

		if event.is_action_pressed("ui_left"):
			selected_item_index = max(0, selected_item_index - 1)
			print(selected_item_index)
			highlight_selected()
		elif event.is_action_pressed("ui_right"):
			if selected_item_index < items_count - 1:
				selected_item_index += 1
			print(selected_item_index)
			highlight_selected()
		elif event.is_action_pressed("interact"):
			if selected_item_index >= 0:
				_open_item_popup(selected_item_index)
