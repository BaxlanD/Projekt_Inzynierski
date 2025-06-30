extends Action
class_name WaterFieldAction

var field_node: Field

func create(character_: CharacterBody2D) -> WaterFieldAction:
	character = character_
	field_node = character.get_tree().get_root().get_node("LevelDemo/Places/Field")
	_start()
	return self

func copy() -> WaterFieldAction:
	return WaterFieldAction.new().create(character)

func _start() -> void:
	if field_node == null:
		print("Field node is null.")
		_finish()
		return
		
	if field_node.curr_state == field_node.state.burning:
		print("Field is burning! Switching to SaveFieldAction.")
		var save_action := SaveFieldAction.new().create(character, field_node)
		save_action.action_finished.connect(_finish)
		save_action._start()
		return

	if field_node.curr_state != field_node.state.unwatered:
		print("Field is not dry.")
		_finish()
		return
	print(field_node.curr_state)
	var inventory: Inventory = character.npc_inventory
	var items: Array[Dictionary] = inventory.get_items()

	for i in items.size():
		var item_data: Dictionary = items[i]
		var packed_scene: PackedScene = item_data.get("packed_scene", null)

		if packed_scene is PackedScene and packed_scene.resource_path == "res://items/item_bucket_full.tscn":
			field_node.set_state(field_node.state.watered)
			print(field_node.curr_state)
			inventory.remove_item(i)
			print("Field watered by NPC.")
			var empty_bucket_scene := preload("res://items/item_bucket.tscn")
			var empty_instance := empty_bucket_scene.instantiate() as Node2D
			empty_instance.global_position = character.global_position + Vector2(30, 5)
			character.get_tree().current_scene.add_child(empty_instance)
			print("Empty bucket dropped on ground.")
			break
		else:
			print("NPC has no full bucket.")

	_finish()

func _finish() -> void:
	action_finished.emit()

func cancel() -> void:
	_finish()
