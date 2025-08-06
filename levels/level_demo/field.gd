extends Place
class_name Field

enum state {unwatered, watered, burning, destroyed}
var curr_state: state = state.unwatered
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	update_visual()
	interactable.interact = _on_interact

func update_visual() -> void:
	var sprite : Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		match curr_state:
			state.unwatered:
				sprite.texture = preload("res://assets/field_unwatered.png")
			state.watered:
				sprite.texture = preload("res://assets/field_watered.png")
			state.burning:
				sprite.texture = preload("res://assets/field_burning.png")
			state.destroyed:
				sprite.texture = preload("res://assets/field_destroyed.png")
				
func set_state(new_state: state) -> void:
	curr_state = new_state
	update_visual()
	
func _on_interact() -> void:
	if curr_state == state.unwatered:
		set_state(state.burning)
		print("Field set on fire!")
		interactable.is_interactable = false
		
func can_accept_item(item: Item) -> bool:
	return item is Bucket_Full

func bucket_interaction(item: Item) -> void:
	if item is Bucket_Full:
		var player := get_tree().get_root().get_node("LevelDemo/Player") as Player
		var bucket := item as Bucket_Full
		bucket.interact_with(self, player)
		
func get_base_interactions() -> Array[Dictionary]:
	var options : Array[Dictionary] = []

	if curr_state == state.unwatered:
		options.append({
			"name": "Burn the field",
			"action": Callable(self, "set_state").bind(state.burning)
		})

	return options
	
func get_item_interactions(item: Item) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	
	if item is Bucket_Full and curr_state == state.unwatered:
		options.append({
			"name": "Water the field",
			"action": Callable(self, "bucket_interaction").bind(item)
		})

	return options
