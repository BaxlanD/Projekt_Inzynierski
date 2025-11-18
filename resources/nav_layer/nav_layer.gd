extends Resource
class_name NavLayer

# Graph point positions
@export var points: Array[Vector2] = []

# Graph connections (using point IDS - which is index in points array)
@export var connections: Array[Vector2i] = []

# Dictionary keys by point name, mapping to coresponding point ID 
@export var named_points: Dictionary[String, int] = {}

func _to_string() -> String:
	return "NavLayer(points: %d, connections: %d, named_points: %s)" % [points.size(), connections.size(), named_points]
