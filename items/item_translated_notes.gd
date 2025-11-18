extends Item
class_name Translated_notes

func initialize() -> void:
	origin_scene_path = "res://items/item_translated_notes.tscn"
	
func get_display_name() -> String:
	return "Translated Notes"

func get_icon() -> Texture:
	return preload("res://assets/translated_notes.png")
