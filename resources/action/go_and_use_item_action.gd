extends Action
class_name GoAndUseItemAction

@export var target_position: Vector2
@export var item_name: String

var current_subaction: Action

func create(character_: CharacterBody2D, target_: Vector2, item_name_: String) -> GoAndUseItemAction:
	character = character_
	target_position = target_
	item_name = item_name_
	_start()
	return self

func copy() -> GoAndUseItemAction:
	return GoAndUseItemAction.new().create(character, target_position, item_name)

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
	current_subaction = UseItemAction.new().create(character, item_name)
	current_subaction.action_finished.connect(_on_use_finished)

func _on_use_finished() -> void:
	_finish()

func _cleanup() -> void:
	current_subaction = null

func _finish() -> void:
	_cleanup()
	action_finished.emit()
