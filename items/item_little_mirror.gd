extends Item
class_name Little_mirror

func initialize() -> void:
	origin_scene_path = "res://items/item_little_mirror.tscn"
	
func get_display_name() -> String:
	return "Little Mirror"

func get_icon() -> Texture:
	return preload("res://assets/items/lusterko_1.png")
