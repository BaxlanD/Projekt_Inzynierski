extends Item
class_name Herbs

func initialize() -> void:
	origin_scene_path = "res://items/item_herbs.tscn"
	
func get_display_name() -> String:
	return "Herbs"

func get_icon() -> Texture:
	return preload("res://assets/items/ziola_2.png")
