extends Node2D

@export var number_of_edges: int = 10

class MyEdge:
	var start: Vector2
	var end: Vector2
	
	func _init(s: Vector2, e: Vector2) -> void:
		start = s
		end = e
	
	func _to_string() -> String:
		return "Edge(%s, %s)" % [start, end]

var edges: Array[MyEdge] = []
var hits: Array[Vector2] = []
var origin: Vector2

func generate_edges(count: int) -> Array[MyEdge]:
	var result: Array[MyEdge] = []
	
	for i in range(count):
		result.push_back(MyEdge.new(
			Vector2(randi_range(-640, 640), randi_range(-360, 360)),
			Vector2(randi_range(-640, 640), randi_range(-360, 360)),
		))
	
	return result

func project_point_on_edges(point: Vector2) -> void:
	for edge in edges:
		var AB: Vector2 = edge.end - edge.start
		var AP: Vector2 = point - edge.start
		var t: float = AP.dot(AB) / AB.dot(AB)
		if 0 < t and t < 1:
			hits.push_back(edge.start + t * AB)

func _ready() -> void:
	edges = generate_edges(number_of_edges)
	queue_redraw()

func _draw() -> void:
	for edge in edges:
		draw_line(edge.start, edge.end, Color.CYAN, 1, true)
	for hit in hits:
		draw_line(origin, hit, Color.HOT_PINK, 1, true)
		draw_circle(hit, 5, Color.RED, true)

func _process(_delta: float) -> void:
	#test_on_click(true)
	test_random(false)

func test_on_click(draw_debug: bool) -> void:
	if Input.is_action_just_pressed("RMB"):
		hits.clear()
		origin = get_global_mouse_position()
		project_point_on_edges(origin)
		if draw_debug: queue_redraw()
		print("NUMBER OF HITS: %d" % [hits.size()])

func test_random(draw_debug: bool) -> void:
	hits.clear()
	origin = Vector2(randi_range(-640, 640), randi_range(-360, 360))
	project_point_on_edges(origin)
	if draw_debug: queue_redraw()
