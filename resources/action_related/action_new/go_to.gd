extends Action
class_name GoTo

@export var where: Vector2
@export var speed_multiplier: float = 1.0

func create(character_: NPCActions, where_: Vector2) -> GoTo:
	character = character_
	where = where_
	return self

func open() -> void:
	character.anchored_agent.set_destination(where)
	character.animated_sprite_2d.play("Walk")
	character.animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func update(delta: float) -> void:
	super(delta)
	character.anchored_agent.move_via_navigation(character, delta)
	_set_sprite_flip()
	if character.anchored_agent.is_navigation_done():
		character.animated_sprite_2d.play("Idle")
		_complete()

func close() -> void:
	action_closed.emit()

func _set_sprite_flip() -> void:
	var facing: float = character.anchored_agent.last_direction.x
	if facing > 0:
		character.animated_sprite_2d.flip_h = false
	if facing < 0:
		character.animated_sprite_2d.flip_h = true


func _on_animated_sprite_2d_animation_finished() -> void:
	character.animated_sprite_2d.play("Idle")
