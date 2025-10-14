extends RefCounted
class_name PointWithId

var pos: Vector2
var id: int

func _init(position: Vector2, point_id: int) -> void:
	pos = position
	id = point_id

func _to_string() -> String:
	return "<pos:" + str(pos) + " id:" + str(id) + ">"
