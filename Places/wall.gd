extends Place
class_name Wall

enum state {solid, damaged, destroyed}
var curr_state: state = state.solid
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	update_visual()
	interactable.interact = _on_interact
	set_meta("_enums", {
		"curr_state": {
			"solid": state.solid,
			"damaged": state.damaged,
			"destroyed": state.destroyed
		}
	})

func update_visual() -> void:
	var sprite : Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		match curr_state:
			state.solid:
				sprite.texture = preload("res://assets/wall.jpg")
			state.damaged:
				sprite.texture = preload("res://assets/wall_damaged.png")
			state.destroyed:
				sprite.texture = preload("res://assets/wall_destroyed.png")
				
		sprite.scale = Vector2(0.02, 0.027)
				
func set_state(new_state: state) -> void:
	curr_state = new_state
	update_visual()
	
func _on_interact() -> void:
	pass
