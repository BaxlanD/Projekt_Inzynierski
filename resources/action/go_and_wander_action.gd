extends Action
class_name GoAndWanderAction

@export var target_position: Vector2
@export_range(0.0, 200.0) var walk_distance_min: float = 20.0
@export_range(0.0, 200.0) var walk_distance_max: float = 70.0
@export_range(0.1, 5) var pause_duration_min: float = 0.1
@export_range(0.1, 5) var pause_duration_max: float = 1.5
@export var item_to_detect: String = ""

var current_subaction: Action
var _was_successful := false

func create(character_: CharacterBody2D, type_: anchor, target_: Vector2, item_to_detect_: String) -> GoAndWanderAction:
	character = character_
	target_position = target_
	type = type_
	item_to_detect = item_to_detect_
	_start()
	return self

func copy() -> GoAndWanderAction:
	var new_action: GoAndWanderAction = GoAndWanderAction.new().create(character, type, target_position, item_to_detect)
	new_action._was_successful = self._was_successful
	return new_action

func update(delta: float) -> void:
	if current_subaction:
		current_subaction.update(delta)

func cancel() -> void:
	if current_subaction:
		current_subaction.cancel()
	_cleanup()

# Private methods
func _start() -> void:
	current_subaction = GoToPointAction.new().create(character, type, target_position)
	current_subaction.action_finished.connect(_on_goto_finished)

func _on_goto_finished() -> void:
	current_subaction = PaceAroundAction.new().create(character, item_to_detect)
	current_subaction.connect("request_pickup", self._on_request_pickup)
	current_subaction.action_finished.connect(_on_wander_finished)
	
	
func _on_request_pickup(item_position: Vector2) -> void:
	if current_subaction:
		current_subaction.action_finished.disconnect(_on_wander_finished)
		current_subaction.cancel()
	
	current_subaction = GoToAndPickupAction.new().create(character, item_position)
	
	current_subaction.connect("pickup_successful", Callable(self, "_on_pickup_successful"))
	current_subaction.action_finished.connect(_on_wander_finished)

func _on_wander_finished() -> void:
	if _was_successful:
		print("Success!")
		set_successful(true)
	else:
		print("Search failed: did not find item ", item_to_detect)
	_finish()
	
func set_successful(value: bool) -> void:
	_was_successful = value
	
func was_successful() -> bool:
	return _was_successful
	
func _on_pickup_successful() -> void:
	_was_successful = true

func _cleanup() -> void:
	current_subaction = null

func _finish() -> void:
	_cleanup()
	action_finished.emit()
