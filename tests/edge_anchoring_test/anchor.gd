extends Marker2D

@onready var anchor_draw: DebugDraw = $AnchorDraw
@onready var edge_anchoring_test: EdgeAnchoringTest = $".."

var current_edge: Edge
var position_on_edge: float

func _ready() -> void:
	current_edge = edge_anchoring_test.edge
	position_on_edge = 0.5
	self.position = get_world_position()

func _physics_process(delta: float) -> void:
	var dir: float = Input.get_axis("RMB", "LMB")
	if dir:
		move_along_edge(delta * 100 * dir)
		anchor_draw.add_point(Vector2.ZERO)
		anchor_draw.draw()

func get_world_position() -> Vector2:
	return current_edge.a.lerp(current_edge.b, position_on_edge)

func move_along_edge(distance: float) -> void:
	position_on_edge += distance / current_edge.lenght()
	if position_on_edge < 0:
		position_on_edge = 0
	
	if 1 < position_on_edge:
		position_on_edge = 1
	self.position = get_world_position()
