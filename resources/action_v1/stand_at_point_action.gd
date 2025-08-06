extends ActionV1
class_name StandAtPointAction

@export var target: Vector2
@export var duration: float

var subaction: ActionV1

# Public methods
func create(character_: CharacterBody2D, type_: anchor, target_: Vector2, duration_: float) -> StandAtPointAction:
	character = character_
	type = type_
	target = target_
	duration = duration_
	_start()
	return self

func copy() -> StandAtPointAction:
	return StandAtPointAction.new().create(character, type, target, duration)

func update(delta: float) -> void:
	if subaction:
		subaction.update(delta)
		return
	
	duration -= delta
	if duration <= 0:
		_finish()

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
