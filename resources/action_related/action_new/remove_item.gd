extends Action
class_name RemoveItem

@export var target_npc_name: String = ""
@export var item_index: int = 0

var _npc_ref: NPCActions = null

func create(character_: NPCActions, target_npc_name_: String, item_index_: int) -> RemoveItem:
	character = character_
	target_npc_name = target_npc_name_
	item_index = item_index_
	return self


func open() -> void:
	for npc in character.get_tree().get_nodes_in_group("NPCs"):
		if npc.name == target_npc_name:
			_npc_ref = npc
			break

	if _npc_ref == null:
		push_warning("RemoveItem: NPC '%s' not found!" % target_npc_name)
		_complete()
		return

	if not _npc_ref.has_node("Inventory"):
		push_warning("RemoveItem: NPC '%s' has no Inventory node!" % target_npc_name)
		_complete()
		return

	var inv: Inventory = _npc_ref.get_node("Inventory")

	if item_index < 0 or item_index >= inv.items.size():
		push_warning("RemoveItem: Invalid item index %d for NPC '%s'" % [item_index, target_npc_name])
		_complete()
		return

	inv.remove_item(item_index)

	_complete()


func update(_delta: float) -> void:
	pass


func close() -> void:
	action_closed.emit()
