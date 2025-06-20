extends "res://items/item.gd"
class_name Sword

func initialize() -> void:
	origin_scene_path = "res://items/item_sword.tscn"
	
func get_display_name() -> String:
	return "Sword"

func get_icon() -> Texture:
	return preload("res://assets/sword_icon.jpg")
