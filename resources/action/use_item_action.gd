extends Action
class_name UseItemAction

@export var item_name: String = ""

func create(character_: CharacterBody2D, item_name_: String) -> UseItemAction:
	character = character_
	item_name = item_name_
	_start()
	return self

func copy() -> UseItemAction:
	return UseItemAction.new().create(character, item_name)

func _start() -> void:
	var inventory: Inventory = character.npc_inventory
	var items: Array[Dictionary] = inventory.get_items()

	for i in items.size():
		var item_data: Dictionary = items[i]
		var packed_scene: PackedScene = item_data.get("packed_scene", null)
		if packed_scene is PackedScene:
			var dummy : Node= packed_scene.instantiate()
			var item_script : Item = dummy.get_node_or_null("Item")
			if item_script and item_script.get_display_name() == item_name:
				if item_script.has_method("use"):
					item_script.use()
					print("Used item:", item_name)
				else:
					print("Item has no 'use' method")
					
				print("Item consumable status:", item_script.consumable)
				if item_script.consumable:
					inventory.remove_item(i)
					print("Item removed from inventory after use")
					
				dummy.queue_free()
				break
			dummy.queue_free()

	_finish()

func _finish() -> void:
	action_finished.emit()

func cancel() -> void:
	_finish()
