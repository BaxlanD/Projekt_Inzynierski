extends Item
class_name Water_jug

func initialize() -> void:
	origin_scene_path = "res://items/item_water_jug.tscn"
	
func get_display_name() -> String:
	return "Water Jug"

func get_icon() -> Texture:
	return preload("res://assets/items/dzbanek_2.png")
