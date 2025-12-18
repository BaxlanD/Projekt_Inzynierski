extends Node2D
class_name Navigator

@export var transitions: Array[Transition] = []
@export var debug_draw: DebugDraw

var nav_layers: Array[NavLayer] = []
var layer_sizes: Array[int] = []

var astar: AStar2D = AStar2D.new()
var named_points_map: Dictionary[String, int] = {}
var point_data_map: Dictionary[int, PointData]
var graph_connections: Array[Vector2i] = []

func _ready() -> void:
	_collect_nav_layers()
	_initialize_points()
	_initialize_connections()
	if debug_draw: debug_draw.draw()
	#print(graph_connections)

# PointData includes: ID, LayerID, Position, Name ("" if none)
func get_point_data(id: int) -> PointData:
	return point_data_map[id]

## API
func generate_path(origin_edge_ids: Vector2i, origin_progress: float, target: Vector2, layer: int = -1) -> Array[PointWithId]:
	# Find edges that origin and target are on
	#var projected_origin: ProjectedPoint = project_point_on_graph(origin)
	var projected_origin: ProjectedPoint = ProjectedPoint.new(astar, origin_edge_ids, origin_progress)
	var projected_target: ProjectedPoint = _project_point_on_graph_layer(target, layer)
	
	# If origin_edge is the same as target_edge and is aligned in same direction
	if projected_origin.edge_ids == projected_target.edge_ids:
		if projected_origin.progress < projected_target.progress:
			return [PointWithId.new(projected_origin.edge.b, projected_origin.edge_ids[1])]
		else:
			return [PointWithId.new(projected_origin.edge.a, projected_origin.edge_ids[0])]
	
	# If origin_edge is the same as target_edge but reversed alignment
	if projected_origin.edge_ids == Vector2i(projected_target.edge_ids[1], projected_target.edge_ids[0]):
		if projected_origin.progress < 1 - projected_target.progress:
			return [PointWithId.new(projected_origin.edge.b, projected_origin.edge_ids[1])]
		else:
			return [PointWithId.new(projected_origin.edge.a, projected_origin.edge_ids[0])]
	
	# If origin_edge is next to target_edge
	if projected_target.edge_ids[0] == projected_origin.edge_ids[0] or projected_target.edge_ids[0] == projected_origin.edge_ids[1]:
		return [PointWithId.new(projected_target.edge.a, projected_target.edge_ids[0]), PointWithId.new(projected_target.edge.b, projected_target.edge_ids[1])]
	if projected_target.edge_ids[1] == projected_origin.edge_ids[0] or projected_target.edge_ids[1] == projected_origin.edge_ids[1]:
		return [PointWithId.new(projected_target.edge.b, projected_target.edge_ids[1]), PointWithId.new(projected_target.edge.a, projected_target.edge_ids[0])]
	
	# If edges are further apart
	var path_id: PackedInt64Array = astar.get_id_path(projected_origin.get_closer_id(), projected_target.get_closer_id())
	
	# Slice begining if further origin point of edge exists in path anyway
	var further: int = path_id.find(projected_origin.get_further_id())
	if further != -1:
		path_id = path_id.slice(further, path_id.size())
	
	# Append further target point at the end if it doesn't exist in path already
	if !path_id.has(projected_target.get_further_id()):
		path_id.append(projected_target.get_further_id())
	
	var path: Array[PointWithId]
	for id in path_id:
		path.push_back(PointWithId.new(astar.get_point_position(id), id))
		
	return path

# WARNING: Shouldn't be used much, I plan to remove in the future
# helper function to get distance between 2 points based on their astar IDS
func get_len(id1: int, id2: int) -> float:
	return (astar.get_point_position(id1) - astar.get_point_position(id2)).length()

# WARNING: Shouldn't be used much, I plan to remove in the future
# helper function to get point position based on it's astar ID
func get_pos(id: int) -> Vector2:
	return astar.get_point_position(id)

func is_transition(connection: Vector2i) -> bool:
	for t in transitions:
		if Vector2i(t.from, t.to) == connection:
			return true
		if Vector2i(t.to, t.from) == connection:
			return true
	return false

func get_transition(connection: Vector2i) -> Action:
	for t in transitions:
		if Vector2i(t.from, t.to) == connection:
			return t.action
		if Vector2i(t.to, t.from) == connection:
			return t.reverse_action
	return null

## IMPL DETAILS
class ProjectedPoint:
	var edge_ids: Vector2i
	var edge: Edge
	var progress: float
	
	func _init(astar_: AStar2D, ids_: Vector2i, progress_: float) -> void:
		edge_ids = ids_
		edge = Edge.new(astar_.get_point_position(ids_[0]), astar_.get_point_position(ids_[1]))
		progress = progress_
	
	func get_point_position() -> Vector2:
		return edge.a + (edge.b - edge.a) * progress
	
	func get_closer() -> Vector2:
		return edge.a if progress < 0.5 else edge.b
	
	func get_further() -> Vector2:
		return edge.a if progress >= 0.5 else edge.b
	
	func get_closer_id() -> int:
		return edge_ids[0] if progress < 0.5 else edge_ids[1]

	func get_further_id() -> int:
		return edge_ids[1] if progress < 0.5 else edge_ids[0]

func _project_point_on_graph(point: Vector2) -> ProjectedPoint:
	var hits: Array[ProjectedPoint] = []

	for connection in graph_connections:
		if is_transition(connection):
			continue ## Shouldn't match to transition edges as valid targets
		var edge: Edge = Edge.new(get_pos(connection.x), get_pos(connection.y))
		var progress: float = edge.project_point(point)
		if 0 <= progress and progress <= 1:
			var hit_point: Vector2 = edge.a + (edge.b - edge.a) * progress
			if hit_point.y >= point.y:
				hits.push_back(ProjectedPoint.new(astar, connection, progress))
	
	hits.sort_custom(func(a: ProjectedPoint, b: ProjectedPoint) -> bool: 
		return a.get_point_position().distance_squared_to(point) < b.get_point_position().distance_squared_to(point)
	)
	return hits[0]


func _project_point_on_graph_layer(point: Vector2, layer: int = -1) -> ProjectedPoint:
	if layer != -1:
		var hits: Array[ProjectedPoint] = []
		for connection in graph_connections:
			if is_transition(connection):
				continue ## Shouldn't match to transition edges as valid targets
			if get_point_data(connection.x).get_layer_id() == layer and get_point_data(connection.y).get_layer_id() == layer:
				var edge: Edge = Edge.new(get_pos(connection.x), get_pos(connection.y))
				var progress: float = edge.project_point(point)
				if 0 <= progress and progress <= 1:
					var hit_point: Vector2 = edge.a + (edge.b - edge.a) * progress
					if hit_point.y >= point.y:
						hits.push_back(ProjectedPoint.new(astar, connection, progress))
						
		hits.sort_custom(func(a: ProjectedPoint, b: ProjectedPoint) -> bool: 
			return a.get_point_position().distance_squared_to(point) < b.get_point_position().distance_squared_to(point)
		)
		return hits[0]
	else:
		return _project_point_on_graph(point)



#region BUILDING_GRAPH

func _collect_nav_layers() -> void:
	for child in get_children():
		if child is LevelLayer:
			@warning_ignore("unsafe_property_access") # There is type-check but Godot forgot
			var nav_layer: NavLayer = child.nav_layer
			if nav_layer != null:
				for i in nav_layer.points.size():
					@warning_ignore("unsafe_property_access")
					nav_layer.points[i] += child.position
				nav_layers.push_back(nav_layer)

func _initialize_points() -> void:
	## Building astar + named_points_map + point_data_map
	var layer_id: int = 0
	for layer in nav_layers:
		var i: int = astar.get_point_count()
		_add_points_to_astar(layer.points, layer_id, i)
		_add_named_points_to_map(layer.named_points, i)
		layer_id += 1

func _initialize_connections() -> void:
	var layer_id: int = 0
	for layer in nav_layers:
		var offset: int = _compute_id_offset(layer_id)
		# within level connections
		for connection in layer.connections:
			astar.connect_points(connection[0]+offset, connection[1]+offset)
			graph_connections.push_back(Vector2i(connection[0]+offset, connection[1]+offset))
			if debug_draw:
				var edge: Edge = Edge.new(
					point_data_map[connection[0]+offset].get_position(), 
					point_data_map[connection[1]+offset].get_position()
				)
				debug_draw.add_line(edge)
		# layer transitions
		for transition in transitions:
			transition.from = named_points_map[transition.from_point]
			transition.to = named_points_map[transition.to_point]
			astar.connect_points(
				named_points_map[transition.from_point], 
				named_points_map[transition.to_point]
			)
			graph_connections.push_back(Vector2i(
				named_points_map[transition.from_point], 
				named_points_map[transition.to_point]
			))
			if debug_draw:
				var edge: Edge = Edge.new(
					get_point_data(named_points_map[transition.from_point]).get_position(), 
					get_point_data(named_points_map[transition.to_point]).get_position()
				)
				debug_draw.add_line(edge)
		layer_id += 1

func _compute_id_offset(layer_id: int) -> int:
	var offset: int = 0
	for i in range(layer_id):
		offset += layer_sizes[i]
	return offset

func _add_points_to_astar(points: Array[Vector2], layer_id: int, start_id: int) -> void:
	var i: int = start_id
	layer_sizes.push_back(points.size())
	for pos in points:
		astar.add_point(i, pos)
		point_data_map[i] = PointData.new(i, layer_id, pos)
		if debug_draw: debug_draw.add_point(pos)
		i += 1

func _add_named_points_to_map(named_points: Dictionary[String, int], start_id: int) -> void:
	for key in named_points.keys() as Array[String]:
		if key in named_points_map:
			printerr("DUPLICATE KEY NAMES %s" % key)
		else:
			#print("added named point %s idx: %d" % [key, (named_points[key] + start_id)])
			named_points_map[key] = named_points[key] + start_id

#endregion BUILDING_GRAPH
