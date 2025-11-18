extends RefCounted
class_name PointData

var _id: int
var _layer_id: int
var _pos: Vector2
var _point_name: String

func _init(id: int, layer_id: int, position: Vector2, point_name: String="") -> void:
	_id = id
	_layer_id = layer_id
	_pos = position
	_point_name = point_name

func _to_string() -> String:
	return "PointData(%d, %d, %s, %s)" % [_id, _layer_id, _pos, _point_name if _point_name != "" else "None"]

func get_id() -> int: return _id
func get_layer_id() -> int: return _layer_id
func get_position() -> Vector2: return _pos
func get_point_name() -> String: return _point_name
