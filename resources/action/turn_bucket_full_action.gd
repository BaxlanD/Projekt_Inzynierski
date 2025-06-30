extends Action
class_name TurnBucketFullAction

func create(character_: CharacterBody2D) -> TurnBucketFullAction:
	character = character_
	_start()
	return self

func copy() -> TurnBucketFullAction:
	return TurnBucketFullAction.new().create(character)

func _start() -> void:
	var inventory: Inventory = character.npc_inventory
	var items: Array[Dictionary] = inventory.get_items()

	for i in items.size():
		var item_data: Dictionary = items[i]
		var path: PackedScene = item_data.get("packed_scene", null)
		if path is PackedScene and path.resource_path == "res://items/item_bucket.tscn":
			inventory.remove_item(i)

			var full_bucket_scene := preload("res://items/item_bucket_full.tscn")
			var full_bucket_instance := full_bucket_scene.instantiate() as Node2D
			var item_script := full_bucket_instance.get_node_or_null("Item") as Item

			if item_script:
				item_script.initialize()
				inventory.add_item(item_script)
				full_bucket_instance.queue_free()
				print("Full Bucket added")
			else:
				print("Full bucket scene is missing 'Item' node")

			break

	_finish()

func _finish() -> void:
	action_finished.emit()

func cancel() -> void:
	_finish()
