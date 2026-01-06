extends Control

const LEVEL_VILLAGE: PackedScene = preload("res://levels/level-village/level_village.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_VILLAGE)
