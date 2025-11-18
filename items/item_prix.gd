extends Item
class_name Prix

func initialize() -> void:
	origin_scene_path = "res://items/item_prix.tscn"
	
func get_display_name() -> String:
	return "Prix Mushroom"

func get_icon() -> Texture:
	return preload("res://assets/prix_mushroom.png")
