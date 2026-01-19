extends Item
class_name Mozaic

func initialize() -> void:
	origin_scene_path = "res://items/item_mozaic.tscn"
	
func get_display_name() -> String:
	return "Mozaic"

func get_icon() -> Texture:
	return preload("res://assets/items/mozaika_2.png")
