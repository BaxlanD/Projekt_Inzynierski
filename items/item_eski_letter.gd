extends Item
class_name Eski_letter

func initialize() -> void:
	origin_scene_path = "res://items/item_eski_letter.tscn"
	
func get_display_name() -> String:
	return "Eski Letter"

func get_icon() -> Texture:
	return preload("res://assets/items/papier_2.png")
