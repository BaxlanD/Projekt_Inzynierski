extends Item
class_name Hammer_New

func initialize() -> void:
	origin_scene_path = "res://items/item_hammer_new.tscn"
	
func get_display_name() -> String:
	return "Hammer_New"

func get_icon() -> Texture:
	return preload("res://assets/nowy_mlotek.jpg")
	
