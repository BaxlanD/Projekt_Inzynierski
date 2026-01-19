extends Item
class_name Renas_potion

func initialize() -> void:
	origin_scene_path = "res://items/item_renas_potion.tscn"
	
func get_display_name() -> String:
	return "Rena's Potion"

func get_icon() -> Texture:
	return preload("res://assets/items/rena_potion_2.png")
