extends Action
class_name GoAndWaterAction

@export var target_position: Vector2

var current_subaction: Action

func create(character_: CharacterBody2D, target_: Vector2) -> GoAndWaterAction:
	character = character_
	target_position = target_
	_start()
	return self

func copy() -> GoAndWaterAction:
	return GoAndWaterAction.new().create(character, target_position)

func update(delta: float) -> void:
	if current_subaction:
		current_subaction.update(delta)

func cancel() -> void:
	if current_subaction:
		current_subaction.cancel()
	_cleanup()

# Private methods
func _npc_has_item(name: String) -> bool:
	var inventory: Inventory = character.npc_inventory
	for item_data in inventory.get_items():
		if item_data.has("display_name") and item_data["display_name"] == name:
			return true
	return false

func _start() -> void:
	current_subaction = GoToPointAction.new().create(character, type, target_position)
	current_subaction.action_finished.connect(_on_goto_finished)

func _on_goto_finished() -> void:
	current_subaction = WaterFieldAction.new().create(character)
	current_subaction.action_finished.connect(_on_water_finished)

func _on_water_finished() -> void:
	var planner: ScheduleNPC = character.get_node_or_null("ScheduleNPC")
	if _npc_has_item("Apple") and planner:
		print("NPC already has apple — skipping wander and pickup.")
		planner.entry_index += 1
		character.bad_day -= 1
	else:
		_finish()

func _cleanup() -> void:
	current_subaction = null

func _finish() -> void:
	_cleanup()
	action_finished.emit()
