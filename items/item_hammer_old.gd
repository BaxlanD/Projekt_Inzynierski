extends Item
class_name Hammer_Old

func initialize() -> void:
	origin_scene_path = "res://items/item_hammer_old.tscn"
	
func get_display_name() -> String:
	return "Hammer_Old"

func get_icon() -> Texture:
	return preload("res://assets/items/hammer_2.png")
	
