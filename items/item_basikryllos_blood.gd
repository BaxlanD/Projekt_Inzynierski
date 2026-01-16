extends Item
class_name Basikryllos_blood

func initialize() -> void:
	origin_scene_path = "res://items/item_basykryllos_blood.tscn"
	
func get_display_name() -> String:
	return "Basikryllos' Blood"

func get_icon() -> Texture:
	return preload("res://assets/items/basilisk_2.png")
