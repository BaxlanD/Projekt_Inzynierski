extends Item
class_name Rope

func initialize() -> void:
	origin_scene_path = "res://items/item_rope.tscn"
	
func get_display_name() -> String:
	return "Rope"

func get_icon() -> Texture:
	return preload("res://assets/items/lina_2.png")
	
