extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			var inventory: Inventory = $Player/Inventory
			if inventory.is_placing_item:
				var world_pos: Vector2 = get_global_mouse_position()
				var player_pos: Vector2 = inventory.player_ref.global_position
				if player_pos.distance_to(world_pos) <= inventory.drop_radius:
					inventory.try_place_selected_item(world_pos)
				else:
					print("Out of range.")
					
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var world_pos := get_global_mouse_position()
			var player := $Player as Player
			player.interact(world_pos)
