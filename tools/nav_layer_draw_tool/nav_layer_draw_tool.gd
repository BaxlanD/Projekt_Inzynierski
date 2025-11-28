@tool
extends Node2D
class_name NavLayerDrawTool

@export var editting: bool = false
@export_tool_button("Undo PointConnection") var undo_button: Callable = _undo_connection

@export_group("Load")
@export var nav_layer_to_load: NavLayer
@export_tool_button("Load Graph") var load_button: Callable = load_graph_from_resource

@export_group("Save")
@export var nav_layer: NavLayer
@export_tool_button("Save Graph") var save_button: Callable = save_graph_to_resource

# Stores connections as [(id1, id2), (id2, id3), ...]
var connections: Array[PointConnection]

# Variables to track selection
var selected_point = null

# Color settings for drawing connections
const LINE_COLOR = Color.CYAN
const POINT_COLOR = Color.PURPLE


func _ready():
	if not Engine.is_editor_hint():
		set_process(false)  # Disable processing outside of the editor


func _process(delta):
	if Engine.is_editor_hint():
		if editting: 
			check_editor_selection()
			queue_redraw()


func _draw():
	## Draw existing connections
	for connection in connections:
		var p1 = connection.point1
		var p2 = connection.point2
		draw_line(p1.position, p2.position, LINE_COLOR, 5)
	
	## Highlight currently selected point if there is one
	if selected_point:
		draw_circle(selected_point.position, 10, POINT_COLOR)


func check_editor_selection():
	## Get currently selected nodes in the editor
	var editor_interface = EditorInterface.get_selection()
	var selected_nodes = editor_interface.get_selected_nodes()
	
	## If there is none: Deselect selected point if there was one
	if selected_nodes.size() == 0:
		selected_point = null
	
	## If there is exactly one and it's NavPoint...
	if selected_nodes.size() == 1 and selected_nodes[0] is NavPoint:
		## If there was no previous selection: Set this node as selected
		if selected_point == null:
			selected_point = selected_nodes[0]
			
		## If there was previous selection: Try to connect both points and clear selection
		elif selected_point != selected_nodes[0]:
			add_connection(selected_point, selected_nodes[0])
			selected_point = null


func add_connection(p1: NavPoint, p2: NavPoint):
	## Make sure connection doesn't already exist
	for c in connections:
		if (c.point1 == p1 or c.point1 == p2) and (c.point2 == p1 or c.point2 == p2):
			print_rich("[color=yellow]This connection already exists[/color]")
			return
	
	## If it's new: Add this new connection to the list
	print_rich("[color=blue]New connection added[/color]")
	connections.append(PointConnection.new(p1,p2))

func save_graph_to_resource() -> void:
	## CLEARNING RESOURCE
	nav_layer = NavLayer.new()
	
	## ADDING POINTS
	var i: int = 0
	for child in get_children():
		if child is NavPoint:
			nav_layer.points.append(child.position)
			if child.point_name != "":
				nav_layer.named_points[child.point_name] = i
			i += 1
	
	## ADDING EDGES
	for c in connections:
		nav_layer.connections.append(Vector2i(c.point1.get_index(), c.point2.get_index()))
	
	print_rich("[color=green]Resource has been updated[/color]")

func load_graph_from_resource() -> void:
	## CHECK IF RESOURCE PROVIDED
	if !nav_layer_to_load:
		print_rich("[color=yellow]There is no NavLayer to load[/color]")
		return
	
	## CLEAR ALL CHILDREN
	for child in get_children():
		child.queue_free()
	
	## CREATING POINTS
	for vec in nav_layer_to_load.points:
		var point: NavPoint = NavPoint.new()
		add_child(point)
		point.owner = get_tree().edited_scene_root
		point.position = vec
	
	## RESTORE NAMES
	for point_name in nav_layer_to_load.named_points.keys():
		var target_point: NavPoint = get_child(nav_layer_to_load.named_points[point_name]) as NavPoint
		target_point.point_name = point_name
		target_point.name = point_name
	
	## RELOADING CONNECTIONS
	connections.clear()
	for edge in nav_layer_to_load.connections:
		var connection: PointConnection = PointConnection.new(get_child(edge[0]), get_child(edge[1]))
		connections.append(connection)
		
	## REDRAW THE GRAPH FROM DATA
	queue_redraw()
	
	## REMOVE LOAD RESOURCE
	nav_layer_to_load = null
	return

func _undo_connection() -> void:
	connections.pop_back()
	queue_redraw()

## Connections dataclass - Basically just Vector2 that stores node references instead of int
class PointConnection:
	var point1: NavPoint
	var point2: NavPoint
	
	func _init(p1: NavPoint, p2: NavPoint):
		point1 = p1
		point2 = p2
