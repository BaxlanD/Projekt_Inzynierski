extends Action
class_name SpawnNPC

@export var npc_path: NodePath

func create(character_: Character) -> SpawnNPC:
	character = character_
	return self

func open() -> void:
	if npc_path == NodePath(""):
		push_error("SpawnNPCAction: npc_path is empty.")
		_complete()
		return

	var scene_root: Node2D = character.get_tree().current_scene
	var npc : NPCActions = scene_root.get_node_or_null(npc_path)

	if npc and npc is NPCActions:
		npc.visible = true
		if npc.interactable:
			npc.interactable.set_process(true)
		npc._actor_setup.call_deferred()
	else:
		push_error("SpawnNPCAction: NPC not found via path: %s" % npc_path)

	_complete()
