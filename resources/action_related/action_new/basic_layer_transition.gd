extends Action
class_name BasicLayerTransition

var animation: String

func create(character_: Character, animation_: String) -> BasicLayerTransition:
	character = character_
	animation = animation_
	return self

func open() -> void:
	_done = false
	character.animated_sprite_2d.play(animation)
	character.animated_sprite_2d.animation_finished.connect(_complete)

## HERE IMPLEMENT MAIN LOOP OF ACTION
func update(_delta: float) -> void:
	_check_timeout()

## HERE IMPLEMENT CLEANUP BEFORE ACTION SHOULD CLOSE
func close() -> void:
	character.anchored_agent.progress_to_next_edge()
	character.anchored_agent._update_actors_world_position(character)
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
