extends Action
class_name PushInstantAction

@export var target_npc_name: String
@export var action_resource: Action


func create(character_: NPCActions, npc_name_: String, action_resource_: Action) -> PushInstantAction:
	character = character_
	target_npc_name = npc_name_
	action_resource = action_resource_
	return self


func open() -> void:
	super()

	if not action_resource or target_npc_name.is_empty():
		push_warning("[PushInstantAction] Missing target NPC name or action resource.")
		_complete()
		return

	var root := character.get_tree().root
	var target_npc := root.find_child(target_npc_name, true, false) as NPCActions

	if not target_npc:
		push_warning("[PushInstantAction] Target NPC not found or invalid: " + target_npc_name)
		_complete()
		return

	var new_action := action_resource.duplicate(true) as Action
	if not new_action:
		push_warning("[PushInstantAction] Failed to duplicate action resource.")
		_complete()
		return

	new_action.character = target_npc

	var seq := Sequence.new().with_fleeting().from_actions([new_action])

	if target_npc.sequence_controller:
		target_npc.sequence_controller.push_instant(seq)
		print("[PushInstantAction] '%s' pushed to NPC '%s' instantly." % [new_action.resource_name, target_npc.name])
	else:
		push_warning("[PushInstantAction] Target NPC has no sequence_controller!")

	_complete()
