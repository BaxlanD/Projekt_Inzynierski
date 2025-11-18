extends Item
class_name Nails

func initialize() -> void:
	origin_scene_path = "res://items/item_nails.tscn"
	
func get_display_name() -> String:
	return "Nails"

func get_icon() -> Texture:
	return preload("res://assets/gwozdzie.jpg")
	
