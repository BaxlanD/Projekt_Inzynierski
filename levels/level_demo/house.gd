extends Place
class_name House

@onready var interactable: Interactable = $Interactable
@export var retain_to_change: Retain

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact() -> void:
	pass

func can_accept_item(item: Item) -> bool:
	return item is Little_mirror


func get_item_interactions(item: Item) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	
	if item is Little_mirror:
		options.append({
			"name": "Leave Mirror",
			"action": Callable(self, "_leave_little_mirror").bind(item)
		})
	
	return options


func _leave_little_mirror(item: Item) -> void:
	var player := get_tree().get_root().get_node("LevelDemo/Player") as Player
	var inventory := player.get_node("Inventory") as Inventory

	var index := inventory.items.find(item)
	if index == -1:
		print("No item in inv")
		return

	inventory.remove_item(index)
	print("Little mirror found.")
	retain_to_change.set_value(1)
