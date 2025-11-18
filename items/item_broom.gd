extends Item
class_name Broom

func initialize() -> void:
	origin_scene_path = "res://items/item_broom.tscn"
	
func get_display_name() -> String:
	return "Broom"

func get_icon() -> Texture:
	return preload("res://assets/broom.jpg")
