extends Item
class_name Dagger

func _init() -> void:
	use_special_inventory = true 

func initialize() -> void:
	origin_scene_path = "res://items/item_dagger.tscn"
	
func get_display_name() -> String:
	return "Dagger"

func get_icon() -> Texture:
	return preload("res://assets/items/sztylet_2.png")
