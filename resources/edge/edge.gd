extends RefCounted
class_name Edge

var a: Vector2
var b: Vector2

func _init(_a: Vector2, _b: Vector2) -> void:
	a = _a
	b = _b

func _to_string() -> String:
	return "Edge(%s, %s)" % [a, b]

func project_point(point: Vector2) -> float:
	var ab: Vector2 = b - a
	var ap: Vector2 = point - a
	return ab.dot(ap) / ab.dot(ab)

func lenght() -> float:
	return (a - b).length()
