extends Action
class_name GiveItem

@export var item_scene_path: String = ""
@export var target_npc_name: String = ""

var _npc_ref: NPCActions = null

func create(character_: NPCActions, item_scene_path_: String, target_npc_name_: String) -> GiveItem:
	character = character_
	item_scene_path = item_scene_path_
	target_npc_name = target_npc_name_
	return self

func open() -> void:
	for npc in character.get_tree().get_nodes_in_group("NPCs"):
		if npc.name == target_npc_name:
			_npc_ref = npc
			break

	if _npc_ref == null:
		push_warning("NPC '%s' not found!" % target_npc_name)
		_complete()
		return
		
	var scene: PackedScene = load(item_scene_path)
	if scene == null:
		push_warning("Cannot load item scene '%s'" % item_scene_path)
		_complete()
		return

	var new_item: Item = scene.instantiate()
	
	if _npc_ref.has_node("Inventory"):
		var inv: Inventory = _npc_ref.get_node("Inventory")
		if inv.has_method("add_item"):
			inv.add_item(new_item)
			print("Item added: %s" % new_item)
		else:
			push_warning("Inventory has no add_item method!")
	else:
		push_warning("NPC has no Inventory node!")

	_complete()

func update(_delta: float) -> void:
	pass

func close() -> void:
	action_closed.emit()
