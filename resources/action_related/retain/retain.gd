extends Resource
class_name Retain

@export var _value: int = 0

func get_value() -> int:
	return _value
	
func set_value(i: int) -> void:
	_value = i
