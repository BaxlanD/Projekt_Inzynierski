class_name Bucket
extends Item

@export var is_full: bool = false

func initialize() -> void:
	if origin_scene_path == "":
		origin_scene_path = "res://items/item_bucket.tscn"

func get_display_name() -> String:
	return "Full Bucket" if is_full else "Bucket"

func get_icon() -> Texture:
	return preload("res://assets/bucket_full.png") if is_full else preload("res://assets/bucket_empty.png")
