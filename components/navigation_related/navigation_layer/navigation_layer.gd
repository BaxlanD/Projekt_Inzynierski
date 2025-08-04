extends Node2D
class_name NavigationLayer
## NOTE: Soooo... ye I ain't cleaning this up
## This needs a rework not a clean up - I will get to it eventually 
## cuz it's quite important piece honestly :/

@export var nav_graph: NavGraph
@export var debug_show_graph: bool = false

@export var _logging: bool = true
@export var projection_draw: DebugDraw


var astar: AStar2D = AStar2D.new()
var ray_cast_2d: RayCast2D = RayCast2D.new()
var ramps_cast_2d: RayCast2D = RayCast2D.new()
var points_by_level: Dictionary = {}

var _recent_path: PackedVector2Array

## Create Navigation Graph based on provided NavGraph resource
func _ready() -> void:
	add_child(ray_cast_2d)
	ray_cast_2d.target_position = Vector2(0,100)
	ray_cast_2d.set_collision_mask_value(1, true)
	ray_cast_2d.set_collision_mask_value(2, true)
	ray_cast_2d.set_collision_mask_value(3, true)
	
	add_child(ramps_cast_2d)
	ramps_cast_2d.target_position = Vector2(288,288)
	ramps_cast_2d.set_collision_mask_value(1, true)
	ramps_cast_2d.set_collision_mask_value(2, true)
	ramps_cast_2d.set_collision_mask_value(3, true)
	
	if nav_graph:
		for i in nav_graph.points.size():
			var new_point_pos: Vector2 = nav_graph.points[i]
			astar.add_point(i, new_point_pos, 1.0)
			if not new_point_pos.y in points_by_level:
				_log("Adding new dict entry: " + str(new_point_pos.y))
				points_by_level[new_point_pos.y] = []
			@warning_ignore("unsafe_method_access")
			points_by_level[new_point_pos.y].append(IDtoPOINTmapping.new(i, new_point_pos))
			
		for level: float in points_by_level:
			@warning_ignore("unsafe_method_access")
			points_by_level[level].sort_custom(func(a: IDtoPOINTmapping, b: IDtoPOINTmapping) -> bool: return a.POS.x < b.POS.x)
		
		for i in nav_graph.edges.size():
			astar.connect_points(nav_graph.edges[i][0], nav_graph.edges[i][1], true)


## Draw points and edges of the generated Navigation Graph
func _draw() -> void:
	if debug_show_graph:
		for id in astar.get_point_ids():
			draw_circle(astar.get_point_position(id), 10, Color.DARK_BLUE)
		for edge in nav_graph.edges:
			draw_line(astar.get_point_position(edge[0]), astar.get_point_position(edge[1]), Color.CYAN, 5)
		
		if _recent_path:
			for i in _recent_path.size():
				draw_circle(_recent_path[i], 9, Color.RED)
				if i != 0:
					draw_line(_recent_path[i-1], _recent_path[i], Color.CORAL, 5)


## Request path in form of Packed Array of points
## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func get_nav_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var path: PackedVector2Array = []
	
	var best_start_id: int  = get_best_point_with_same_elevation(from, to)
	var start: Vector2 = astar.get_point_position(best_start_id)
	var end: Vector2 = astar.get_closest_position_in_segment(to)
	
	## NOTE: FIX THIS, THIS COULD BE SLIGHTLY BETTER PROBABLY
	path.append(start)
	path.append_array(astar.get_point_path(best_start_id, astar.get_closest_point(to)))
	path.append(end)
	return path

## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func get_closest_point_with_same_elevation(from: Vector2) -> int:
	var closest_id: int = -1
	for id in nav_graph.points.size():
		## Check if point has same elevation as start point
		if nav_graph.points[id].y == from.y:
			## Check if point is closer than previous closest
			if (nav_graph.points[closest_id] - from).length() > (nav_graph.points[id] - from).length() or closest_id == -1:
				closest_id = id
	return closest_id

## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func get_best_point_with_same_elevation(from: Vector2, target: Vector2) -> int:
	var best_id: int = -1
	var best_score: float = 10000.0
	
	## Loop through all the points
	for id in nav_graph.points.size():
		## Check if point has same elevation as start point
		if nav_graph.points[id].y == from.y:
			## Check if point better than previous best
			if best_score > (nav_graph.points[id] - target).length()  or best_id == -1:
				best_id = id
				best_score = (nav_graph.points[id] - target).length()
				
	return best_id

## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func get_good_nav_path(start: Vector2, target: Vector2) -> PackedVector2Array:
	_log("=====================")
	## Move both Vector2s to ground level (so they are reachable)
	ray_cast_2d.position = start + Vector2.UP
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		start = ray_cast_2d.get_collision_point()
	else:
		_log("Couldn't ground navigation point [start]")
		_log("OH NO")
		return []
	
	ray_cast_2d.position = target + Vector2.UP
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		target = ray_cast_2d.get_collision_point()
	else:
		_log("Couldn't ground navigation point [target]")
		_log("OH NO")
		return []
	
	## Find 2 points next to start and target
	## If on flat ground -> Search points on this level
	## Return as Array[Vector2] = [Right_point, Left_point]
	## If on the ramp -> Find bottom point and get neighbour which is higher
	## Return as Array[Vector2] = [Bottom_point, Top_point]
	
	var start_result: Array[int] = find_reachable(start)
	var target_result: Array[int] = find_reachable(target)
	
	## NOTE: This should probably be inside find_reachable() function. Unmessify it later pls, me
	## NOTE: If we make disabled points, this should also check if reachable is disabled probably
	start_result = sort_reachable(start_result, start)
	target_result = sort_reachable(target_result, target)
		
	## Run Astar Pathfinding
	## from start's Closer_point
	## to target's Closer_point
	
	_log("RESULTS")
	_log(str(start_result))
	_log(str(target_result))
	
	var path: PackedVector2Array
	
	if start_result == target_result:
		path = PackedVector2Array([target])
		_log("PATH" + str(path))
		_recent_path = path
		queue_redraw()
		return path
	
	path = astar.get_point_path(start_result[0], target_result[0])
	
	## If start's Further_point appears on the path
	## Slice away everything earlier in the path than Further_point
	## If target's Further_point appears on the path
	## Slice away everything after in the path than Further_point
	var alt_start: Vector2 = astar.get_point_position(start_result[1])
	var alt_target: Vector2 = astar.get_point_position(target_result[1])
	
	_log("PATH ORIGINAL" + str(path))
	
	_log("ALT START " + str(alt_start))
	_log("ALT TARGET" + str(alt_target))
	
	var ps: int = path.find(alt_start)
	if ps != -1:
		_log("slice start")
	else:
		ps = 0
	_log(str(ps))
	
	var pe: int = path.find(alt_target)
	if pe != -1:
		_log("slice end")
	else:
		pe = path.size()
	
	if pe < ps:
		path.clear()
	else:
		path = path.slice(ps, pe)
		
	_log("SLICED PATH" + str(path))
	
	## Append target at the end of the path
	path.append(target)
	_log("PATH ADD TARGET" + str(path))
	## Return final path to the agent
	
	_recent_path = path
	queue_redraw()
	return path

## NOTE: Argument origin should be at floor level to accurately search graph
## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func find_reachable(origin: Vector2) -> Array[int]:
	var reachable_ids: Array[int] = []
	_log("-----")
	## If origin is on the flat ground
	_log("ORIGIN.Y: " + str(origin.y))
	if origin.snapped(Vector2(0.01, 0.01)).y in points_by_level:
		_log("ON FLAT")
		origin.y = origin.snapped(Vector2(0.01, 0.01)).y
		_log("SNAPPED Y: " + str(origin.y))
		@warning_ignore("unsafe_method_access")
		for i: float in points_by_level[origin.y].size():
			var point: IDtoPOINTmapping = points_by_level[origin.y][i]
			if origin.x - point.POS.x < 0:
				reachable_ids.append(points_by_level[origin.y][i-1].ID)
				reachable_ids.append(points_by_level[origin.y][i].ID)
				break
		
		return reachable_ids
		
	## If origin is on the ramp
	else:
		_log("ON SLOPE")
		_log("DEFAULT ORIGIN: " + str(origin))
		_log("SNAPPED ORIGIN: " + str(origin.snapped(Vector2(1, 1))))
		
		ray_cast_2d.position = origin + Vector2.UP
		ray_cast_2d.force_raycast_update()
		var normal: Vector2 = ray_cast_2d.get_collision_normal()

		if 0 < normal.x:
			ramps_cast_2d.position = origin.snapped(Vector2(1,1)) + Vector2(16,0)
			ramps_cast_2d.target_position.x = 288
		else:
			ramps_cast_2d.position = origin.snapped(Vector2(1,1)) + Vector2(-16,0)
			ramps_cast_2d.target_position.x = -288
			
		ramps_cast_2d.force_raycast_update()
		
		var floor_point: Vector2 = ramps_cast_2d.get_collision_point().snapped(Vector2(1,1))
		var floor_id: int
		_log("FLOOR POINT: " + str(floor_point))
		
		for point: IDtoPOINTmapping in points_by_level[floor_point.y]:
			if point.POS == floor_point:
				floor_id = point.ID
				_log("floor point found!")
				break
		
		for id in astar.get_point_connections(floor_id):
			if astar.get_point_position(id).y < floor_point.y:
				reachable_ids.append(floor_id)
				reachable_ids.append(id)
		
		return reachable_ids

## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
func sort_reachable(reachable: Array[int], origin: Vector2) -> Array[int]:
	var vec1: Vector2 = astar.get_point_position(reachable[0])
	var vec2: Vector2 = astar.get_point_position(reachable[1])
	
	if vec1.distance_to(origin) > vec2.distance_to(origin):
		var array: Array[int] = [reachable[1], reachable[0]]
		return array
	
	return reachable

func _log(content: String) -> void:
	if _logging:
		print(content)
		
## @deprecated: Legacy navigation function - use [NavigationLayer.generate_path]
## Dataclass to store points for quicker lookup time
class IDtoPOINTmapping:
	var ID: int
	var POS: Vector2
	
	func _init(id: int, pos: Vector2) -> void:
		ID = id
		POS = pos

func project_on_edges(point: Vector2) -> Vector2i:
	var closest_distance: float = INF
	var closest_edge: Edge = null
	var closest_id: Vector2i
	var hits: Array[Vector2]
	for edge in nav_graph.edges:
		var e: Edge = Edge.new(nav_graph.points[edge.x], nav_graph.points[edge.y])
		var t: float = e.project_point(point)
		if 0 < t and t < 1:
			var hit_point: Vector2 = e.a + (e.b - e.a) * t
			if hit_point.y >= point.y:
				if hit_point.distance_to(point) < closest_distance:
					closest_distance = hit_point.distance_to(point)
					closest_edge = e
					closest_id = edge
				hits.push_back(hit_point)
	
	hits.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.distance_to(point) < b.distance_to(point))
	projection_draw.add_line(Edge.new(point, hits[0]))
	projection_draw.add_line(closest_edge)
	projection_draw.add_point(hits[0])
	return closest_id

func generate_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start_edge: Vector2i = project_on_edges(from)
	var end_edge: Vector2i = project_on_edges(to)
	projection_draw.draw()
	
	## I SHOULDN'T RECALCULATE THE IMPACT POINT AGAIN
	## BUT IT'S WHATEVER FOR NOW
	var hit_point: Vector2 = nav_graph.points[end_edge[0]] + (nav_graph.points[end_edge[1]] - nav_graph.points[end_edge[0]]) * Edge.new(nav_graph.points[end_edge[0]], nav_graph.points[end_edge[1]]).project_point(to)
	
	if start_edge == end_edge:
		return PackedVector2Array([hit_point])
	
	var path: PackedVector2Array = astar.get_point_path(start_edge[0], end_edge[0])
	
	var front: int = path.find(nav_graph.points[start_edge[1]])
	if front != -1:
		path = path.slice(front)
	
	var back: int = path.find(nav_graph.points[end_edge[1]])
	if back != -1:
		path = path.slice(0, back+1)
	
	path.append(hit_point)
	
	_recent_path = path
	queue_redraw()
	return path

func get_pos(point_id: int) -> Vector2:
	return astar.get_point_position(point_id)
