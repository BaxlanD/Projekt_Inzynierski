extends Node
class_name AnchoredAgent

# General export const
@export var SPEED: float = 180

# Connection to navigation layer
@export_category("Navigation")
@export var navigation_layer: NavigationLayerV2
@export var debug_draw_path: DebugDraw

# Position should be counted from id0 towards id1
var current_edge_ids: Vector2i
var progress: float

# Relating to navigation-based movement
var _path: Array[PointWithId] = []
var _path_index: int = 0
var _target_position: Vector2

# Keep last movement direction for the sake of the animations I guess?
var last_direction: Vector2

## API
func initialize(actor: Node2D) -> void:
	var projected_position := navigation_layer._project_point_on_graph(actor.position)
	current_edge_ids = projected_position.edge_ids
	progress = projected_position.progress

func set_destination(target: Vector2) -> void:
	_path = navigation_layer.generate_path(current_edge_ids, progress, target)
	_path_index = 0
	## TODO: Shouldn't run the projection on target twice - fix if possible
	_target_position = navigation_layer._project_point_on_graph(target).get_point_position()
	if current_edge_ids[1] != _path[0].id:
		_reverse_current_edge()
	_debug_draw_path_if_enabled()

func is_navigation_done() -> bool:
	return _path.is_empty()

func move_via_navigation(actor: Node2D, delta: float) -> void:
	if _path.is_empty():
		return # Should probably signal that path is done for action
	
	var distance: float = SPEED * delta
	
	while 0 < distance:
		_update_last_direction()
		# IF LAST EDGE 
		if _path_index == _path.size() - 1:
			var dist_to_target: float = actor.position.distance_to(_target_position)
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
			var dist_to_edge_end: float = actor.position.distance_to(_path[_path_index].pos)
			var current_edge_len: float = navigation_layer.get_len(current_edge_ids[0], current_edge_ids[1])
			# IF OVERSHOT EDGE END
			if distance > dist_to_edge_end:
				progress = 0
				distance -= dist_to_edge_end
				## PROGRESS TO NEXT EDGE 
				_path_index += 1
				current_edge_ids = Vector2i(current_edge_ids[1], _path[_path_index].id)
			# ELSE MOVE AS FAR AS YOU NEED
			else:
				progress += distance / current_edge_len
				distance = 0
	
	_update_actors_world_position(actor)

func move_via_input(actor: Node2D, delta: float, dir: Vector2) -> void:
	## GET INPUT
	_reset_navigation()
	var distance: float = SPEED * delta
	
	if not _align_current_edge_with_input(dir):
		return

	## Move by distance along current edge
	var edge_length: float = navigation_layer.get_len(current_edge_ids[0], current_edge_ids[1])
	progress += distance / edge_length
	distance = (progress - 1) * edge_length
	
	while distance > 0:
		_update_last_direction()
		## Choose new edge
		var best_id: int = _get_best_new_edge(current_edge_ids[1], dir)
		if best_id == -1:
			distance = 0
			progress = 1
		else:
			current_edge_ids = Vector2i(current_edge_ids[1], best_id)
			progress = 0
		## Move by remaining distance along current edge
		edge_length = navigation_layer.get_len(current_edge_ids[0], current_edge_ids[1])
		progress += distance / edge_length
		distance = (progress - 1) * edge_length
	
	_update_actors_world_position(actor)

## IMPL DETAILS
func _reverse_current_edge() -> void:
	current_edge_ids = Vector2i(current_edge_ids[1], current_edge_ids[0])
	progress = 1 - progress

func _update_last_direction() -> void:
	var point1: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids[0])
	var point2: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids[1])
	last_direction = (point2 - point1).normalized()

func _update_actors_world_position(actor: Node2D) -> void:
	var point1: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids[0])
	var point2: Vector2 = navigation_layer.astar.get_point_position(current_edge_ids[1])
	actor.position = point1 + (point2 - point1) * progress

func _reset_navigation() -> void:
	_path.clear()

func _align_current_edge_with_input(direction: Vector2) -> bool:
	var min_dot: float = 0.25
	var edge_vector: Vector2 = (navigation_layer.get_pos(current_edge_ids[1]) - navigation_layer.get_pos(current_edge_ids[0])).normalized()
	var dot: float = 0.0
	
	# UP/DOWN Vector
	dot = Vector2(0, direction.y).normalized().dot(edge_vector)
	# If angle is acceptable
	if min_dot < abs(dot):
		if dot < 0:
			_reverse_current_edge()
		return true
	
	# LEFT/RIGHT Vector
	dot = Vector2(direction.x, 0).normalized().dot(edge_vector)
	# If angle is acceptable
	if min_dot < abs(dot):
		if dot < 0:
			_reverse_current_edge()
		return true
	
	return false

func _get_best_new_edge(point_id: int, dir: Vector2) -> int:
	var cons := navigation_layer.astar.get_point_connections(point_id)
	var pos: Vector2 = navigation_layer.astar.get_point_position(point_id)
	var best_id: int = -1
	var best_score: float = -INF
	for con in cons:
		if con == current_edge_ids[0]:
			continue
		var score: float = (navigation_layer.astar.get_point_position(con) - (pos)).normalized().dot(dir)
		if score > best_score:
			best_score = score
			best_id = con
	return best_id

func _debug_draw_path_if_enabled() -> void:
	if debug_draw_path:
		for i in _path.size() - 1:
			debug_draw_path.add_line(Edge.new(_path[i].pos, _path[i+1].pos))
		debug_draw_path.add_point(_target_position)
		debug_draw_path.draw()
