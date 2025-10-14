extends ActionV1
class_name AnimateAtPointAction

@export var target: Vector2
@export var animation_name: String

var subaction: ActionV1

# Public methods
func create(character_: NPC, type_: anchor, target_: Vector2, animation_name_: String) -> AnimateAtPointAction:
	character = character_
	type = type_
	target = target_
	animation_name = animation_name_
	_start()
	return self

func copy() -> AnimateAtPointAction:
	return AnimateAtPointAction.new().create(character, type, target, animation_name)

func update(delta: float) -> void:
	if subaction:
		subaction.update(delta)
		return
	
	character.animated_sprite_2d.play(animation_name)

func cancel() -> void:
	if subaction:
		subaction.cancel()
	_cleanup()

# Private methods
func _start() -> void:
	subaction = GoToPointAction.new().create(character, type, target)
	subaction.action_finished.connect(_subaction_callback)

func _cleanup() -> void:
	pass

func _finish() -> void:
	_cleanup()
	action_finished.emit()

func _subaction_callback() -> void:
	subaction = null
	character.animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	_finish()
