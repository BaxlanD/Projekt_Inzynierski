extends Resource
class_name Action

signal action_completed
signal action_closed

@export var timeout: int = 0
var recall: bool = false
var character: NPCActions

func open() -> void:
	pass

func update(_delta: float) -> void:
	## Every update needs to include this check manually or by calling super(delta)
	if is_timed_out():
		action_completed.emit()
		close()

func close() -> void:
	action_closed.emit()

func with_recall() -> Action:
	recall = true
	return self

func with_timeout(value: int) -> Action:
	timeout = value
	return self

func is_timed_out() -> bool:
	if timeout == 0:
		return false
	if character.action_controller.elapsed_time < timeout:
		return false
	return true
