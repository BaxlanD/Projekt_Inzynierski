extends Action
class_name StandAtPointAction

var obj: Node2D
var target: Vector2
var duration: float

var subaction: Action
var restore_state: Color

func _init(obj_: Node2D, target_: Vector2, duration_: float, type_: anchor) -> void:
	# initialize
	obj = obj_
	target = target_
	duration = duration_
	type = type_
	# change obj state
	obj.modulate = Color.GREEN
	restore_state = obj.modulate
	# start subaction
	subaction = GoToPointAction.new(obj, target, anchor.OVERRIDE)
	subaction.action_finished.connect(_subaction_callback)

func update(delta: float) -> void:
	if subaction:
		subaction.update(delta)
		return
	
	duration -= delta
	if duration <= 0:
		_finish()

func cancel() -> void:
	_cleanup()

func _finish() -> void:
	_cleanup()
	action_finished.emit()

func _cleanup() -> void:
	obj.modulate = Color.WHITE

func _subaction_callback() -> void:
	obj.modulate = restore_state
	subaction = null
