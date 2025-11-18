extends Area2D
class_name Interactable

enum type {item, place, npc}
@export var interact_name: String = ""
@export var is_interactable: bool = true
@export var interaction_type: type = type.item

var interact: Callable
