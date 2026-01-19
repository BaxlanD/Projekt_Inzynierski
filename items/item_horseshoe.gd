extends Item
class_name Horseshoe

func initialize() -> void:
	origin_scene_path = "res://items/item_horseshoe.tscn"
	
func get_display_name() -> String:
	return "Horseshoe"

func get_icon() -> Texture:
	return preload("res://assets/items/wiadro_2.png")
	
