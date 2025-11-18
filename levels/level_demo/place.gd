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
	
func get_place_interactions(_npc: NPCActions) -> Array[Dictionary]:
	return []
	
func execute_place_interaction(_npc: NPCActions, _interaction_id: String) -> void:
	pass
	
func update_visual() -> void:
	pass
				
