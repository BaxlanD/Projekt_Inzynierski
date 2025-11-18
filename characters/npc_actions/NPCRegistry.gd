extends Node

var npcs: Dictionary = {}

func register_npc(npc_name: String, node: Node2D) -> void:
	npcs[npc_name] = node

func get_npc(npc_name: String) -> Node2D:
	return npcs.get(npc_name)
