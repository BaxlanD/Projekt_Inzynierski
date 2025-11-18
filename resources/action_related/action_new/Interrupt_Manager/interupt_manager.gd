extends Node
class_name InteruptManager

var interupts: Array[InteruptDefinition] = []
var _triggered: Dictionary = {}
var _pending := {}

func add_interupt(def: InteruptDefinition) -> void:
	interupts.append(def)
	
func signal_ready(def: InteruptDefinition, npc_name: String) -> bool:
	if not def:
		return false

	if not _pending.has(def):
		_pending[def] = []
	var arr: Array = _pending[def]
	if npc_name in arr:
		return false
	arr.append(npc_name)

	var needed := def.participants_required
	if needed <= 0:
		needed = max(1, def.linked_npcs.size())

	if arr.size() >= needed:
		_pending.erase(def)
		_trigger_all_for_def(def)
		return true

	return false
	
func _trigger_all_for_def(def: InteruptDefinition) -> void:
	var all_participants: Array = []
	all_participants.append_array(def.linked_npcs)

	all_participants = all_participants.duplicate()
	all_participants = all_participants.map(func(n): return str(n))

	var unique_participants: Array[String] = []
	for n: String in all_participants:
		if n not in unique_participants:
			unique_participants.append(n)
	all_participants = unique_participants

	for npc_name: String in all_participants:
		var npc := _find_npc_by_name(npc_name)
		if not npc:
			print("[InteruptManager] Target not found:", npc_name)
			continue

		npc._execute_interupt_for_def(def)
		mark_triggered(def, npc_name)

	print("[InteruptManager] Triggered interrupt for:", all_participants)

func clear_ready(def: InteruptDefinition) -> void:
	if _pending.has(def):
		_pending.erase(def)

func find_for_item(item_name: String, npc: NPCActions) -> InteruptDefinition:
	for def in interupts:
		if not def.requires_item:
			continue
		
		if def.item_name == item_name and npc.get_current_sequence_name() in def.allowed_sequences:
			return def
			
	return null
	
func was_triggered(def: InteruptDefinition, npc_name: String) -> bool:
	if not def.trigger_once:
		return false
	var key := str(def.resource_name) + "_" + str(npc_name)
	return _triggered.has(key)

func mark_triggered(def: InteruptDefinition, npc_name: String) -> void:
	if not def.trigger_once:
		return
	var key := str(def.resource_name) + "_" + str(npc_name)
	_triggered[key] = true

func reset_triggered() -> void:
	_triggered.clear()
	
func _find_npc_by_name(_name: String) -> NPCActions:
	var npc: NPCActions = NpcRegistry.get_npc(_name)
	if npc:
		return npc as NPCActions
	return null
