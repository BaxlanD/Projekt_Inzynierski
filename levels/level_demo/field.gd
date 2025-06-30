extends Area2D
class_name Field

enum state {unwatered, watered, burning, destroyed}
var curr_state: state = state.unwatered

func _ready() -> void:
	update_visual()

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
