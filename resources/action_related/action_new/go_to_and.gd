extends Action
class_name GoToAnd

var _subaction: Action
@export var where: Vector2
@export var layer: int = -1

func _create(character_: Character, where_: Vector2, layer_: int = -1) -> GoToAnd:
	character = character_
	where = where_
	layer = layer_
	return self

func open() -> void:
	_done = false
	_subaction = GoTo.new().create(character, where, layer)
	_subaction.action_closed.connect(_on_subaction_closed)
	_subaction.open()

## HERE IMPLEMENT MAIN LOOP OF ACTION
func update(delta: float) -> void:
	_check_timeout()
	_subaction.update(delta)

## HERE IMPLEMENT CLEANUP BEFORE ACTION SHOULD CLOSE
func close() -> void:
	action_closed.emit()

func _on_subaction_closed() -> void:
	_subaction = null
