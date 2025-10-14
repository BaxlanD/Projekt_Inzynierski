extends Node2D
class_name NavigationLayerV2

@export var nav_graph: NavGraph
@export var debug_show_graph: bool = false

var astar: AStar2D = AStar2D.new()

func _ready() -> void:
	assert(nav_graph)
	for i in nav_graph.points.size():
		astar.add_point(i, nav_graph.points[i])
	for edge in nav_graph.edges:
		astar.connect_points(edge.x, edge.y)

func _draw() -> void:
	for point_id in astar.get_point_ids():
		draw_circle(astar.get_point_position(point_id), 5, Color.AQUA)
		for connection_id in astar.get_point_connections(point_id):
			if connection_id < point_id:
				draw_line(astar.get_point_position(point_id), astar.get_point_position(connection_id), Color.AQUA, 3)

## API
func generate_path(origin_edge_ids: Vector2i, origin_progress: float, target: Vector2) -> Array[PointWithId]:
	# Find edges that origin and target are on
	#var projected_origin: ProjectedPoint = project_point_on_graph(origin)
	var projected_origin: ProjectedPoint = ProjectedPoint.new(astar, origin_edge_ids, origin_progress)
	var projected_target: ProjectedPoint = _project_point_on_graph(target)
	
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
	for connection in nav_graph.edges:
		var edge: Edge = Edge.new(nav_graph.points[connection.x], nav_graph.points[connection.y])
		var progress: float = edge.project_point(point)
		if 0 <= progress and progress <= 1:
			var hit_point: Vector2 = edge.a + (edge.b - edge.a) * progress
			if hit_point.y >= point.y:
				hits.push_back(ProjectedPoint.new(astar, connection, progress))
	
	hits.sort_custom(func(a: ProjectedPoint, b: ProjectedPoint) -> bool: 
		return a.get_point_position().distance_squared_to(point) < b.get_point_position().distance_squared_to(point)
	)
	return hits[0]
