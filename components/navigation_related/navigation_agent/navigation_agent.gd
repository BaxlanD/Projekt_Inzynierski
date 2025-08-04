extends Node
class_name NavigationAgent

@export var _link_desired_distance: int

var _character: NPCActions
var _navigation_layer: NavigationLayer

var _path: PackedVector2Array = []
var _index: int = 0
var _next: Vector2

func initialize(character: NPCActions, navigation_layer: NavigationLayer) -> void:
	_character = character
	_navigation_layer = navigation_layer

func set_navigation_target(target: Vector2) -> void:
	_index = 0
	_path = _navigation_layer.generate_path(_character.position, target)
	_next = _path[0]

func get_next_path_position() -> Vector2:
	## Should check is_navigaton_finished() before calling lol
	return _path[_index]

func is_navigation_finished() -> bool:
	# Clear 'reached' links first
	while _index < _path.size() and _character.position.distance_to(_path[_index]) < _link_desired_distance:
		_index += 1
	
	if _index < _path.size():
		return false
	else:
		return true
