extends Item
class_name Healing_scroll

func initialize() -> void:
	origin_scene_path = "res://items/item_healing_scroll.tscn"
	
func get_display_name() -> String:
	return "Healing Scroll"

func get_icon() -> Texture:
	return preload("res://assets/spell-scroll.jpg")
