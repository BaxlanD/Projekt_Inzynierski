extends ActionV1
class_name TurnBucketFullAction

func create(character_: CharacterBody2D) -> TurnBucketFullAction:
	character = character_
	_start()
	return self

func copy() -> TurnBucketFullAction:
	return TurnBucketFullAction.new().create(character)

func _start() -> void:
	var inventory: Inventory = character.npc_inventory
	var items: Array[Item] = inventory.get_items()

	for i in items.size():
		var item: Item = items[i]
		if item.origin_scene_path == "res://items/item_bucket.tscn":
			inventory.remove_item(i)

			var full_bucket_scene := preload("res://items/item_bucket_full.tscn")
			var new_item := full_bucket_scene.instantiate() as Item

			if new_item:
				new_item.initialize()
				inventory.add_item(new_item)
				print("Full Bucket added to inventory")
			else:
				print("Error: instantiated full bucket is not an Item.")

			break

	_finish()


func _finish() -> void:
	action_finished.emit()

func cancel() -> void:
	_finish()
