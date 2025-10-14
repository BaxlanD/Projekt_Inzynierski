extends Item
class_name Bucket

func initialize() -> void:
	if origin_scene_path == "":
		origin_scene_path = "res://items/item_bucket.tscn"

func get_display_name() -> String:
	return "Bucket"

func get_icon() -> Texture:
	return preload("res://assets/bucket_empty.png")
