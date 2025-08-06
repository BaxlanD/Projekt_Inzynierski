extends Item
class_name Bucket_Full

func can_interact_with(target: Node2D) -> bool:
	return target is Field

func interact_with(target: Node2D, player: Player) -> void:
	var field := target as Field
	if field.curr_state == Field.state.unwatered:
		field.set_state(Field.state.watered)
		print("Field watered!")
		var inventory: Inventory = player.get_inventory()
		var index := inventory.get_items().find(self)
		if index != -1:
			inventory.remove_item(index)
			
		var empty_bucket_scene := preload("res://items/item_bucket.tscn")
		var empty_bucket := empty_bucket_scene.instantiate() as Item
		
		if empty_bucket:
			empty_bucket.initialize()
			inventory.add_item(empty_bucket)

func initialize() -> void:
	origin_scene_path = "res://items/item_bucket_full.tscn"
	
func get_display_name() -> String:
	return "Bucket (Full)"

func get_icon() -> Texture:
	return preload("res://assets/bucket_full.png")
