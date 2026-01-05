extends Area2D
class_name Interactable

enum type {item, place, npc}
@export var interact_name: String = ""
@export var is_interactable: bool = true
@export var interaction_type: type = type.item

var interact: Callable

func get_actor_layer() -> int:
	var p := get_parent()
	if not p:
		return -1
		
	for child in p.get_children():
		if child is AnchoredAgentV2:
			@warning_ignore("unsafe_property_access")
			return child.actor_layer
			
	if "actor_layer" in p:
		@warning_ignore("unsafe_property_access")
		return p.actor_layer
		
	return -1
