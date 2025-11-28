extends Node
class_name GameClock

signal start_clock
signal stop_clock

var _playing: bool = false
var _elapsed_time: float
var _exceptions: Array[SequenceController] = []

func start() -> void:
	_exceptions.clear()
	_playing = true
	start_clock.emit()

func stop(exceptions: Array[SequenceController] = []) -> void:
	_exceptions = exceptions
	_playing = false
	stop_clock.emit()

func reset() -> void:
	_elapsed_time = 0.0

## For SequenceController to use
func get_game_time() -> float:
	return _elapsed_time

func allow_processing(sequence_controller: SequenceController) -> bool:
	if _playing:
		return true
	if sequence_controller in _exceptions:
		return true
	return false

#region YOU SHOULDN"T CARE WHAT"S BELOW

func _ready() -> void:
	start()

func _process(delta: float) -> void:
	## MOCKUP ONLY - REMOVE 
	if Input.is_action_just_pressed("test"):
		if _playing:
			stop()
		else:
			start()
	
	if _playing:
		_elapsed_time += delta

#endregion YOU SHOULDN"T CARE WHAT"S BELOW
