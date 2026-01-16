extends Item
class_name Wooden_spoon

func initialize() -> void:
	origin_scene_path = "res://items/item_wooden_spoon.tscn"
	
func get_display_name() -> String:
	return "Wooden Spoon"

func get_icon() -> Texture:
	return preload("res://assets/items/chochla_2.png")
