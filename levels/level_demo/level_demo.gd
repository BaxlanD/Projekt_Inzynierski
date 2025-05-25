extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
		print("Clicked on scene, is_placing_item =", $UI/InventoryUI.is_placing_item)
		var inventory = $UI/InventoryUI
		if inventory.is_placing_item:
			var world_pos = get_global_mouse_position()
			var player_pos = inventory.player_ref.global_position
			if player_pos.distance_to(world_pos) <= inventory.DROP_RADIUS:
				inventory.place_item_in_world(world_pos)
			else:
				print("Out of range.")
