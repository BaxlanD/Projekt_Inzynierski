extends Action
class_name GoToPointAction

var obj: Node2D
var target: Vector2

func _init(obj_: Node2D, target_: Vector2, type_: anchor) -> void:
	obj = obj_
	target = target_
	type = type_
	obj.modulate = Color.RED

func update(delta: float) -> void:
	var dir: Vector2 = (target - obj.position).normalized()
	obj.position += dir * 200 * delta
	
	if (obj.position - target).length() < 5:
		_finish()

func cancel() -> void:
	_cleanup()

func _finish() -> void:
	_cleanup()
	action_finished.emit()

func _cleanup() -> void:
	obj.modulate = Color.WHITE
