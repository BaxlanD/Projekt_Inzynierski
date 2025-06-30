extends "res://items/item.gd"
class_name Apple

func _init() -> void:
	consumable = true

func initialize() -> void:
	origin_scene_path = "res://items/item_apple.tscn"
	
func get_display_name() -> String:
	return "Apple"

func get_icon() -> Texture:
	return preload("res://assets/apple.png")
	
func use() -> void:
	print("Yummy!")
