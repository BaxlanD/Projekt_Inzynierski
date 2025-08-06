extends Node2D
class_name Place

func _on_interact() -> void:
	pass
		
func can_accept_item(_item: Item) -> bool:
	return false
		
func get_base_interactions() -> Array[Dictionary]:
	return []
	
func get_item_interactions(_item: Item) -> Array[Dictionary]:
	return []
