extends Resource
class_name Action

signal action_finished

enum anchor{SCHEDULE, OVERRIDE}
var type: anchor

var character: CharacterBody2D

## Call this when duplicating action from blueprint action object
## Never use already existing action object
func copy() -> Action:
	return

## Call every frame while action is active
func update(_delta: float) -> void:
	pass

## Call always when you *manually* change action
## Manually means, you attempt to override current action,
## instead of waiting for action_finished signal
func cancel() -> void:
	pass
