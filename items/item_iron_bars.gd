extends Item
class_name Iron_bars

func initialize() -> void:
	origin_scene_path = "res://items/item_iron_bars.tscn"
	
func get_display_name() -> String:
	return "Iron Bars"

func get_icon() -> Texture:
	return preload("res://assets/iron_bars.jpg")
