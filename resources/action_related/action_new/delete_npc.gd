extends Action
class_name DeleteNPC

@export var npc_path: NodePath

func open() -> void:
	if npc_path == NodePath(""):
		push_warning("DeleteNPC: npc_path is empty.")
		_complete()
		return

	var scene_root: Node2D = character.get_tree().current_scene
	var npc : NPCActions = scene_root.get_node_or_null(npc_path)

	if npc and npc is NPCActions:
		npc.visible = false
		if npc.interactable:
			npc.interactable.set_process(false)
		npc.character_stop()
	else:
		push_warning("DeleteNPC: NPC not found via path: %s" % npc_path)

	_complete()
