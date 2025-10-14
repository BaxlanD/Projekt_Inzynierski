extends Resource
class_name ActionV1

signal action_finished

enum anchor{SCHEDULE, OVERRIDE}
var type: anchor = anchor.SCHEDULE

var character: NPC

## Call this when duplicating action from blueprint action object
## Never use already existing action object
func copy() -> ActionV1:
	return ActionV1.new()

## Call every frame while action is active
func update(_delta: float) -> void:
	pass

## Call always when you *manually* change action
## Manually means, you attempt to override current action,
## instead of waiting for action_finished signal
func cancel() -> void:
	pass
