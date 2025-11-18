extends Action
class_name DeleteItem

@export var item_name: String

func create(character_: NPCActions, item_: Item) -> DeleteItem:
	character = character_
	item_name = item_.name
	return self

func open() -> void:
	var items := character.get_tree().get_nodes_in_group("items")

	for node in items:
		if node.name == item_name:
			node.queue_free()
			break

	_complete()
