extends Item
class_name Chair

func _init() -> void:
	consumable = true

func initialize() -> void:
	origin_scene_path = "res://items/item_chair.tscn"
	
func get_display_name() -> String:
	return "Chair"

func get_icon() -> Texture:
	return preload("res://assets/items/krzesło_2.png")
	
