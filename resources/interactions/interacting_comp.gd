extends Node2D

@onready var label: Label = $Label
var current_interactions: Array = []
var can_interact:= true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and current_interactions:
		can_interact = false
		label.hide()
			
		var target: Interactable = current_interactions[0]
		match target.interaction_type:
			target.type.item, target.type.npc:
				await target.interact.call()
			target.type.place:
				await open_interaction_menu_for(target)
			
		can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable:
			label.text = current_interactions[0].interact_name
			label.show()
	else:
		label.hide()
		
func _sort_by_nearest(a1: Node2D, a2: Node2D) -> bool:
	var a1_dist: float = global_position.distance_to(a1.global_position)
	var a2_dist: float = global_position.distance_to(a2.global_position)
	return a1_dist < a2_dist

func _on_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

func _on_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
	
func open_interaction_menu_for(target: Area2D) -> void:
	var place: Place = target.get_parent()
	var inventory: Inventory = get_tree().get_root().get_node("LevelDemo/Player/Inventory")
	var options: Array[Dictionary] = []

	if place.has_method("get_base_interactions"):
		options += place.get_base_interactions()

	if place.has_method("get_item_interactions"):
		for item in inventory.items:
			options += place.get_item_interactions(item)


	var menu : InteractionMenu = get_tree().get_root().get_node_or_null("LevelDemo/UI/InteractionMenu")
	if menu:
		get_tree().paused = true
		await get_tree().process_frame
		menu.show_menu(options)
		await menu.wait_for_choice()
		get_tree().paused = false
	else:
		push_error("Nie znaleziono InteractionMenu w drzewie!")
