extends Item
class_name Gold_coins

func initialize() -> void:
	origin_scene_path = "res://items/item_gold_coins.tscn"
	
func get_display_name() -> String:
	return "Coins"

func get_icon() -> Texture:
	return preload("res://assets/items/jablko_2.png")
