extends Item
class_name Beer

@export var full : bool = false

func _init() -> void:
	consumable = true

func initialize() -> void:
	origin_scene_path = "res://items/item_beer.tscn"
	
func get_display_name() -> String:
	return "Beer"

func get_icon() -> Texture:
	return preload("res://assets/mocny_full.jpg")
	
func use() -> void:
	if full:
		print("Gulp gulp gulp")
	else:
		print("No beer? :(")
