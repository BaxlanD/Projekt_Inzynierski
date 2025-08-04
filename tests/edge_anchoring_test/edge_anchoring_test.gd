extends Node2D
class_name EdgeAnchoringTest

@onready var debug_draw: DebugDraw = $DebugDraw

var edge: Edge = Edge.new(Vector2(-100, 0), Vector2(100, 0))

func _ready() -> void:
	debug_draw.add_line(edge)
	debug_draw.add_point(edge.a)
	debug_draw.add_point(edge.b)
	debug_draw.draw()

 
