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
	var items: Array[Item] = inventory.get_items()

	for i in items.size():
		var item: Item = items[i]
		if item.get_display_name() == item_name:
			if item.has_method("use"):
				item.use()
				print("Used item:", item_name)
			else:
				print("Item has no 'use' method")

			print("Item consumable status:", item.consumable)
			if item.consumable:
				inventory.remove_item(i)
				print("Item removed from inventory after use")
			break

	_finish()

func _finish() -> void:
	action_finished.emit()

func cancel() -> void:
	_finish()
