extends Item
class_name Bread

func initialize() -> void:
	origin_scene_path = "res://items/item_bread.tscn"
	
func get_display_name() -> String:
	return "Bread"

func get_icon() -> Texture:
	return preload("res://assets/items/chleb_2.png")
