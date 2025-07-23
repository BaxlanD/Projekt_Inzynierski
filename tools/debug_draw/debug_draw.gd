extends Node2D
class_name DebugDraw

@export var debug_draw: bool = true

@export_category("Line")
@export var line_color: Color = Color.WHITE
@export var line_width: float = 2

@export_category("point")
@export var point_color: Color = Color.WHITE
@export var point_width: float = 5

var _edges: Array[Edge]
var _points: Array[Vector2]

func add_line(edge: Edge) -> DebugDraw:
	_edges.push_back(edge)
	return self

func add_lines(edges: Array[Edge]) -> DebugDraw:
	_edges.append_array(edges)
	return self

func add_point(point: Vector2) -> DebugDraw:
	_points.push_back(point)
	return self

func draw() -> void:
	queue_redraw()

func _draw() -> void:
	if debug_draw:
		for edge in _edges:
			draw_line(edge.a, edge.b, line_color, line_width, true)
		for point in _points:
			draw_circle(point, point_width, point_color, true)
			
	_edges.clear()
	_points.clear()
	
