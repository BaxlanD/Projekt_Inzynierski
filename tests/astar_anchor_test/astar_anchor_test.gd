extends Node2D
class_name AstarAnchorTest

@export var navigation_layer: NavigationLayer
@export var navigation_agent: NavigationAgent
@export var anchor_test_draw: DebugDraw
@onready var path_draw: DebugDraw = $"../DebugDraws/PathDraw"

var current_edge_ids: Vector2i = Vector2i.ZERO
var progress: float

var _path: Array[PointWithId] = []
var _path_index: int = 0
var _target: Vector2

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
		#_path = navigation_layer.generate_path(position, get_global_mouse_position())
		_path = navigation_layer.gen(current_edge_ids, progress, get_global_mouse_position())
		_path_index = 0
		_target = navigation_layer.project_point_on_graph(get_global_mouse_position()).get_point_position()
		for i in _path.size() - 1:
			path_draw.add_line(Edge.new(_path[i].pos, _path[i+1].pos))
		path_draw.draw()
		print("CLICK")
		print("current_edge_ids:", current_edge_ids)
		print("first path node id:", _path[0].id)
		
		# Align current edge to point towards path start
		if navigation_layer.get_pos(current_edge_ids[0]) == _path[0].pos:
			current_edge_ids = Vector2i(current_edge_ids[1], current_edge_ids[0])
			progress = 1 - progress
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
	
	while 0 < distance:
		# IF LAST EDGE 
		if _path_index == _path.size() - 1:
			var dist_to_target: float = self.position.distance_to(_target)
			var current_edge_len: float = navigation_layer.get_len(current_edge_ids[0], current_edge_ids[1])
			# IF OVERSHOT TARGET -> STOP AT TARGET
			if distance > dist_to_target:
				progress += dist_to_target / current_edge_len
				distance = 0
				_path.clear()
				_path_index = 0
			# ELSE MOVE AS FAR AS YOU NEED
			else:
				progress += distance / current_edge_len
				distance = 0
		# IF NOT LAST EDGE
		else:
			var dist_to_edge_end: float = self.position.distance_to(_path[_path_index].pos)
			var current_edge_len: float = navigation_layer.get_len(current_edge_ids[0], current_edge_ids[1])
			# IF OVERSHOT EDGE END
			#print("dist: %s | dist_to_edge_end: %s | current_edge: %s | progress: %s | pos: %s " % [distance, dist_to_edge_end, current_edge_ids, progress, position])
			if distance > dist_to_edge_end:
				progress = 0
				distance -= dist_to_edge_end
				## PROGRESS TO NEXT EDGE 
				_path_index += 1
				current_edge_ids = Vector2i(current_edge_ids[1], _path[_path_index].id)
				## TODO
			# ELSE MOVE AS FAR AS YOU NEED
			else:
				progress += distance / current_edge_len
				distance = 0
	position = get_world_position()

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
