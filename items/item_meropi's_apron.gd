extends Item
class_name Meropi_apron

func initialize() -> void:
	origin_scene_path = "res://items/item_meropi's_apron.tscn"
	
func get_display_name() -> String:
	return "Meropi's Apron"

func get_icon() -> Texture:
	return preload("res://assets/items/apron_2.png")
