extends Item
class_name Tint

func initialize() -> void:
	origin_scene_path = "res://items/item_tint.tscn"
	
func get_display_name() -> String:
	return "Tint"

func get_icon() -> Texture:
	return preload("res://assets/tint.jpg")
	
