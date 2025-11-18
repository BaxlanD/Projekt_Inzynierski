extends Panel
@onready var interacting_comp : InteractingComponent = $"../../../Player/InteractingComp"
@onready var inventory_ui: InventoryUI = $".." 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inv"):
		visible = !visible
		inventory_ui.is_open = !inventory_ui.is_open
		interacting_comp.can_interact = !interacting_comp.can_interact
