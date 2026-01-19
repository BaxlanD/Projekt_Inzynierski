extends Item
class_name Invisibility_potion

func _init() -> void:
	use_special_inventory = true 

func initialize() -> void:
	origin_scene_path = "res://items/item_invisibility_potion.tscn"
	
func get_display_name() -> String:
	return "Invisibility Potion"

func get_icon() -> Texture:
	return preload("res://assets/items/ziola_1.png")
