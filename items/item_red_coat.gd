extends Item
class_name Red_coat

func initialize() -> void:
	origin_scene_path = "res://items/item_red_coat.tscn"
	
func get_display_name() -> String:
	return "Red Coat"

func get_icon() -> Texture:
	return preload("res://assets/items/czerwony_plaszcz_3.png")
