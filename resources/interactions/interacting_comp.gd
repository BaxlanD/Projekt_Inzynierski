extends Node2D
class_name InteractingComponent

@onready var label: Label = $Label
var current_interactions: Array = []
var can_interact:= true

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or not can_interact:
		return

	var valid := _get_valid_interactions()
	if valid.is_empty():
		return

	valid.sort_custom(_sort_by_nearest)
	var target: Interactable = valid[0]

	can_interact = false
	label.hide()

	match target.interaction_type:
		target.type.item:
			await target.interact.call()
		target.type.place, target.type.npc:
			await open_interaction_menu_for(target)

	can_interact = true

func _process(_delta: float) -> void:
	if not can_interact:
		label.hide()
		return

	var valid := _get_valid_interactions()
	if valid.is_empty():
		label.hide()
		return

	valid.sort_custom(_sort_by_nearest)
	var target: Interactable = valid[0]

	label.text = target.interact_name
	label.show()
		
func _sort_by_nearest(a1: Node2D, a2: Node2D) -> bool:
	var a1_dist: float = global_position.distance_to(a1.global_position)
	var a2_dist: float = global_position.distance_to(a2.global_position)
	return a1_dist < a2_dist

func _on_range_area_entered(area: Area2D) -> void:
	if area is Interactable:
		current_interactions.push_back(area)
	else:
		call_deferred("_add_area_later", area)

func _add_area_later(area: Area2D) -> void:
	if area is Interactable:
		current_interactions.push_back(area)

func _on_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
	
func _get_valid_interactions() -> Array:
	var player : Player = get_parent()
	if not player:
		return []
		
	var player_layer: int = player.anchored_agent.actor_layer
	
	return current_interactions.filter(func(i: Interactable) -> bool:
		return i.is_interactable and i.get_actor_layer() == player_layer
	)
	
func open_interaction_menu_for(target: Area2D) -> void:
	var interaction_target: Node = target.get_parent()
	var inventory: Inventory = get_tree().get_root().get_node("LevelVillage/Player/Inventory")
	var options: Array[Dictionary] = []
	
	if interaction_target.has_method("get_base_interactions"):
		@warning_ignore("unsafe_method_access")
		options += interaction_target.get_base_interactions()

	if interaction_target.has_method("get_item_interactions"):
		for item in inventory.items:
			@warning_ignore("unsafe_method_access")
			options += interaction_target.get_item_interactions(item)
			
	if interaction_target.has_method("get_place_interactions") and "target_npc_name" in interaction_target:
		@warning_ignore("unsafe_property_access")
		var npc_name: String = interaction_target.target_npc_name
		var npc: NPCActions = NpcRegistry.get_npc(npc_name)
		if npc:
			@warning_ignore("unsafe_method_access")
			options += interaction_target.get_place_interactions(npc)


	var menu : InteractionMenu = get_tree().get_root().get_node_or_null("LevelVillage/UI/InteractionMenu")
	if menu:
		get_tree().paused = true
		await get_tree().process_frame
		menu.show_menu(options)
		await menu.wait_for_choice()
		get_tree().paused = false
	else:
		push_error("Nie znaleziono InteractionMenu w drzewie!")
