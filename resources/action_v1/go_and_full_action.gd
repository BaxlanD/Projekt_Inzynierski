extends ActionV1
class_name GoAndFullAction

@export var target_position: Vector2

var current_subaction: ActionV1

func create(character_: CharacterBody2D, target_: Vector2) -> GoAndFullAction:
	character = character_
	target_position = target_
	_start()
	return self

func copy() -> GoAndFullAction:
	return GoAndFullAction.new().create(character, target_position)

func update(delta: float) -> void:
	if current_subaction:
		current_subaction.update(delta)

func cancel() -> void:
	if current_subaction:
		current_subaction.cancel()
	_cleanup()

# Private methods
func _start() -> void:
	current_subaction = GoToPointAction.new().create(character, type, target_position)
	current_subaction.action_finished.connect(_on_goto_finished)

func _on_goto_finished() -> void:
	current_subaction = TurnBucketFullAction.new().create(character)
	current_subaction.action_finished.connect(_on_full_finished)

func _on_full_finished() -> void:
	_finish()

func _cleanup() -> void:
	current_subaction = null

func _finish() -> void:
	_cleanup()
	action_finished.emit()
