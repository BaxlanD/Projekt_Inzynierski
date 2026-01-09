extends Action
class_name GoTo

@export var where: Vector2
@export var layer: int = -1
@export var speed_multiplier: float = 1.0

var _subaction: Action

func create(character_: Character, where_: Vector2, layer_: int = -1) -> GoTo:
	character = character_
	where = where_
	layer = layer_
	return self

func open() -> void:
	character.anchored_agent.set_destination(where, layer)
	character.animated_sprite_2d.play("Walk")
	character.animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func update(delta: float) -> void:
	super(delta)
	
	if _subaction != null:
		_subaction.update(delta)
		return
	
	character.anchored_agent.move_via_navigation(character, delta)
	
	var new_transition: Action = character.anchored_agent.get_current_transition()
	if new_transition != null:
		var a: Action = new_transition.duplicate()
		a.character = character
		_subaction = a
		_subaction.action_closed.connect(_on_subaction_closed)
		_subaction.open()
	
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

func _on_subaction_closed() -> void:
	_subaction = null
	character.animated_sprite_2d.play("Walk")
