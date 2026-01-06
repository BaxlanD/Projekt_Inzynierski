extends Control

func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://levels/level-village/level_village.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
