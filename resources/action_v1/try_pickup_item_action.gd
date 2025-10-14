extends ActionV1
class_name TryPickupItemAction

var subaction: Action

func create(character_: CharacterBody2D) -> TryPickupItemAction:
	character = character_
	_start()
	return self

func copy() -> TryPickupItemAction:
	return TryPickupItemAction.new().create(character)

func update(_delta: float) -> void:
	if not is_instance_valid(character):
		_finish()
		return

	if character.npc_inventory.get_items().size() > 0:
		print("NPC already has an item.")
		_finish()
		return

	var pickup_area := character.pickup_area
	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("items") and area is Item:
			var item := area as Item

			if character.npc_inventory.add_item(item):
				item.visible = false
				item.set_deferred("monitoring", false)
				item.set_deferred("collision_layer", 0)
				item.set_deferred("collision_mask", 0)

				print("NPC picked up item")

				break

	_finish()

func cancel() -> void:
	_cleanup()

# Private methods
func _start() -> void:
	pass

func _cleanup() -> void:
	pass

func _finish() -> void:
	_cleanup()
	action_finished.emit()
