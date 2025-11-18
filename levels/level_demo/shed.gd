extends Place
class_name Shed

@onready var interactable: Interactable = $Interactable
@export var retain_to_change: Retain

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact() -> void:
	pass

func can_accept_item(item: Item) -> bool:
	return item is Eski_letter


func get_item_interactions(item: Item) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	
	if item is Eski_letter:
		options.append({
			"name": "Leave E'ski's Letter",
			"action": Callable(self, "_leave_eski_letter").bind(item)
		})
	
	return options


func _leave_eski_letter(item: Item) -> void:
	var player := get_tree().get_root().get_node("LevelDemo/Player") as Player
	var inventory := player.get_node("Inventory") as Inventory

	var index := inventory.items.find(item)
	if index == -1:
		print("No item in inv")
		return

	inventory.remove_item(index)
	print("Eski Letter found.")

	var scene := load("res://items/item_eski_letter.tscn") as PackedScene
	if scene:
		var new_letter := scene.instantiate() as Item
		get_tree().get_root().get_node("LevelDemo").add_child(new_letter)
		new_letter.global_position = global_position + Vector2(-40, 0)
		retain_to_change.set_value(1)
	else:
		print("Could not load Eski Letter.")
