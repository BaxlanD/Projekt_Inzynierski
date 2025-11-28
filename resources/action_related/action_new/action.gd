extends Resource
class_name Action

signal action_closed

var character: Character
var _done: bool = false

@export var _fleeting: bool = false
@export var _timeout: int = 0

## ATTENTION
## EVERY SUBCLASS NEEDS TO HAVE create() METHOD
## THIS IS WHERE YOU WILL PASS ARGUMENTS DURING ACTION CREATION
## BECAUSE OPEN NEEDS TO BE POLYMORPHIC TO NUMBER OF ARGS SADLY

## NOTE
## IT WOULD BE GOOD IF YOU CALLED SUPER IN EVERY ONE OF YOUR OVERIDES
## PROBABLY AT THE END OF EACH, BECAUSE OF close()

## HERE IMPLEMENT INITIALIZATION LOGIC
func open() -> void:
	_done = false

## HERE IMPLEMENT MAIN LOOP OF ACTION
func update(_delta: float) -> void:
	_check_timeout()

## HERE IMPLEMENT CLEANUP BEFORE ACTION SHOULD CLOSE
func close() -> void:
	action_closed.emit()

## METHODS BELOW ARE IMPLEMENTED AND SHOULDN'T BE CHANGED IN SUBCLASSES
## CALLED INTERNALLY
func _complete() -> void:
	_done = true
	close()

func _is_timed_out() -> bool:
	if 0 < _timeout and _timeout < character.sequence_controller.get_time():
		return true
	return false

func _check_timeout() -> void:
	if _is_timed_out():
		_done = true
	if is_done():
		close()

## CALLED EXTERNALLY
func is_done() -> bool:
	if _done:
		return true
	else:
		return _is_timed_out()

func is_fleeting() -> bool:
	return _fleeting

func with_fleeting() -> Action:
	_fleeting = true
	return self

func with_timeout(value: int) -> Action:
	_timeout = value
	return self
