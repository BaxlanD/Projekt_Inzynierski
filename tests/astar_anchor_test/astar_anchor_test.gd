extends Node2D
class_name AstarAnchorTest

@export var navigation_layer: NavigationLayer
@export var navigation_agent: NavigationAgent
@export var anchor_test_draw: DebugDraw

var current_edge_ids: Vector2i = Vector2i.ZERO
var progress: float
var _path: PackedVector2Array = []
var _path_index: int = 0

func _ready() -> void:
	current_edge_ids = navigation_layer.nav_graph.edges[99]
	progress = 0.5
	self.position = get_world_position()

func _physics_process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	## Prioritize Free-move
	if dir != Vector2.ZERO:
		_path.clear()
		free_move(180 * delta, dir)
	
	## Then navigate 
	if Input.is_action_just_pressed("RMB"):
		_path = navigation_layer.generate_path(position, get_global_mouse_position())
	navigate_move(180 * delta)
	
	anchor_test_draw.add_line(Edge.new(position, position + Vector2(dir.x, 0) * 30))
	anchor_test_draw.add_line(Edge.new(position, position + Vector2(0, dir.y) * 30))
	anchor_test_draw.add_point(self.position)
	anchor_test_draw.draw()

func get_world_position() -> Vector2:
	var pos1: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids.x)
	var pos2: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids.y)
	return pos1.lerp(pos2, progress)

func free_move(distance: float, direction: Vector2) -> void:
	if not _align_current_edge_direction(direction):
		return
	## Move by distance along current edge
	var edge_length: float = (navigation_layer.get_pos(current_edge_ids[1]) - navigation_layer.get_pos(current_edge_ids[0])).length()
	progress += distance / edge_length
	distance = (progress - 1) * edge_length
	
	while distance > 0:
		## Choose new edge
		var best_id: int = _get_best_new_edge(current_edge_ids[1], direction)
		if best_id == -1:
			distance = 0
			progress = 1
		else:
			current_edge_ids = Vector2i(current_edge_ids[1], best_id)
			progress = 0
		## Move by remaining distance along current edge
		edge_length = (navigation_layer.get_pos(current_edge_ids[1]) - navigation_layer.get_pos(current_edge_ids[0])).length()
		progress += distance / edge_length
		distance = (progress - 1) * edge_length
	
	position = get_world_position()

func navigate_move(distance: float) -> void:
	if _path.is_empty():
		return
	
	position += position.direction_to(_path[_path_index]) * min(distance, position.distance_to(_path[_path_index]))
	if position.distance_to(_path[_path_index]) < 1:
		_path_index += 1
		
	if _path_index >= _path.size():
		_path.clear()
		_path_index = 0
	
	#while distance > 0 and _path_index < _path.size():
		#print(distance)
		#var next_link: Vector2 = _path[0]
		#if position.distance_to(next_link) > distance:
			#position += (next_link - position).normalized() * distance
			#distance = 0
			#_path_index += 1
		#else:
			#position = next_link
			#distance -= (next_link - position).length()
	
	

func _align_current_edge_direction(direction: Vector2) -> bool:
	var min_dot: float = 0.25
	var edge_vector: Vector2 = (navigation_layer.get_pos(current_edge_ids[1]) - navigation_layer.get_pos(current_edge_ids[0])).normalized()
	var dot: float = 0.0
	
	# UP/DOWN Vector
	dot = Vector2(0, direction.y).normalized().dot(edge_vector)
	# If angle is acceptable
	if min_dot < abs(dot):
		_align_edge_direction(dot)
		return true
	
	# LEFT/RIGHT Vector
	dot = Vector2(direction.x, 0).normalized().dot(edge_vector)
	# If angle is acceptable
	if min_dot < abs(dot):
		_align_edge_direction(dot)
		return true
	
	return false

func _align_edge_direction(dot: float) -> void:
	if dot < 0:
		current_edge_ids = Vector2i(current_edge_ids[1], current_edge_ids[0])
		progress = 1 - progress

func _get_best_new_edge(point_id: int, dir: Vector2) -> int:
	var cons := navigation_layer.astar.get_point_connections(point_id)
	var pos: Vector2 = navigation_layer.astar.get_point_position(point_id)
	var best_id: int = -1
	var best_score: float = -INF
	for con in cons:
		if con == current_edge_ids[0]:
			continue
		var score: float = (navigation_layer.astar.get_point_position(con) - (pos)).normalized().dot(dir)
		#print("POINT %s | WITH SCORE: %s" % [navigation_layer.get_pos(con), score])
		if score > best_score:
			#print("NEW BEST")
			best_score = score
			best_id = con
	#print("BEST ID %s" % best_id)
	return best_id
