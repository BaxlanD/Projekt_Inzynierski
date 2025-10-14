extends Node2D

@onready var player := $Player as Player

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
					
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos := get_global_mouse_position()
			var space_state := get_world_2d().direct_space_state

			var query := PhysicsPointQueryParameters2D.new()
			query.position = mouse_pos
			query.collide_with_areas = true
			query.collide_with_bodies = true

			var results: Array[Dictionary] = space_state.intersect_point(query)

			for hit in results:
				if hit.has("collider"):
					var collider: Node2D = hit["collider"]
					if collider.has_method("interact"):
						if player:
							player.try_interact(collider)
						break
				
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			player.clear_held_item()
