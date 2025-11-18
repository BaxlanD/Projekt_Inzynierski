extends Control
class_name InteractionMenu

@onready var panel: Panel = $Panel
@onready var container: VBoxContainer = $Panel/VBoxContainer

var is_open: bool = false
var selected_index := 0
var buttons := []
var actions := []

signal menu_closed
signal option_selected(action: Callable)

func _ready() -> void:
	panel.visible = false 
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.set_size(Vector2(200, 100)) 
	var stylebox := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if stylebox:
		stylebox.bg_color = Color.RED

func show_menu(options: Array[Dictionary]) -> void:
	clear_menu()
	buttons.clear()
	actions.clear()
	selected_index = 0
		

	for i in range(options.size()):
		var opt: Dictionary = options[i]
		var button := Button.new()
		button.text = opt["name"]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.focus_mode = Control.FOCUS_NONE
		container.add_child(button)

		buttons.append(button)
		actions.append(opt["action"])
		
	var cancel_button := Button.new()
	cancel_button.text = "Do nothing"
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cancel_button.focus_mode = Control.FOCUS_NONE
	container.add_child(cancel_button)

	buttons.append(cancel_button)
	actions.append(Callable())
	
	panel.show()
	show()
	is_open = true
	set_process_unhandled_input(true)
	select_button(0)
	
	await get_tree().process_frame
	select_button(0)
	

func select_button(index: int) -> void:
	selected_index = clamp(index, 0, buttons.size() - 1)
	for i in range(buttons.size()):
		var btn : Button = buttons[i]
		if i == selected_index:
			btn.add_theme_color_override("font_color", Color.YELLOW)
			var stylebox := panel.get_theme_stylebox("normal") as StyleBoxFlat
			if stylebox:
				stylebox.bg_color = Color.DARK_GRAY
		else:
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_stylebox_override("normal")
			

func clear_menu() -> void:
	for child in container.get_children():
		child.queue_free()
		
func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % buttons.size()
		print(selected_index)
		select_button(selected_index)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		print(selected_index)
		select_button(selected_index)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("interact"):
		if selected_index >= 0 and selected_index < actions.size():
			var action: Callable = actions[selected_index]
			hide_menu()
			if action != null and action.is_valid():
				action.call()
				option_selected.emit(action)
			get_viewport().set_input_as_handled()

func wait_for_choice() -> Signal:
	return self.menu_closed

func hide_menu() -> void:
	hide()
	is_open = false
	clear_menu()
	emit_signal("menu_closed")
