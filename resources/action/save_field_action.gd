extends Action
class_name SaveFieldAction

var field_node: Field

func create(character_: CharacterBody2D, field_: Field) -> SaveFieldAction:
	character = character_
	field_node = field_
	return self

func _start() -> void:
	
	var planner: ScheduleNPC = character.get_node_or_null("ScheduleNPC")
	print("NPC is attempting to extinguish the fire...")

	var inventory: Inventory = character.npc_inventory
	var items: Array[Item] = inventory.get_items()
	var found := false

	for i in items.size():
		var item: Item = items[i]
		if item.origin_scene_path == "res://items/item_bucket_full.tscn":
			field_node.set_state(Field.state.destroyed)
			inventory.remove_item(i)
			print("Fire extinguished, field destroyed.")
			character.bad_day += 1

			var empty_bucket_scene := preload("res://items/item_bucket.tscn")
			var empty_instance := empty_bucket_scene.instantiate() as Node2D
			empty_instance.global_position = character.global_position + Vector2(30, 5)
			character.get_tree().current_scene.add_child(empty_instance)
			print("Empty bucket dropped.")

			if planner:
				planner.modify_entry_duration(3, 30.0)
				planner.modify_entry_animation(3, "Death")

			found = true
			break
			
	if not found:
		print("NPC has no full bucket!")
		character.bad_day += 2

	_finish()

func _finish() -> void:
	action_finished.emit()
