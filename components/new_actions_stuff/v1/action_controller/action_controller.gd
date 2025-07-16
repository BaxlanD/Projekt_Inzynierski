extends Node
class_name ActionController

@onready var character: NPCActions = $".."
var elapsed_time: float
var current_action: Action

var _schedule: ActionSchedule
var _recall: ActionRecall
var _sequencer: ActionSequencer

var _started: bool = false
var _queued_override: Action

func start() -> void:
	_started = true
	elapsed_time = 0.0
	for child in get_children():
		if child is ActionSchedule:
			_schedule = child
			_schedule.start(character)
		if child is ActionRecall:
			_recall = child
			_recall.start(character)
		if child is ActionSequencer:
			_sequencer = child
			_sequencer.start(character)
			
	_open_action()

func update(delta: float) -> void:
	if not _started:
		return
	elapsed_time += delta
	if current_action:
		current_action.update(delta)

func request_override(override: Action) -> void:
	_queued_override = override
	if current_action:
		current_action.close()
	else:
		_open_action()

func force_override(override: Action) -> void:
	_queued_override = override
	_open_action()

func _open_action() -> void:
	if current_action:
		current_action.action_closed.disconnect(_on_action_closed)
		current_action = null
	
	## 1) Attempt to get override if avilable
	current_action = _queued_override
	_queued_override = null
	
	## 2) Attempt to revive from recall is avilable
	if not current_action and _recall:
		current_action = _recall.revive()
	
	## 3) Attempt to get from schedule if avilable
	if not current_action and _schedule:
		current_action = _schedule.get_current_action()
	
	## 4) Attempt to get from sequencer if avilable
	if not current_action and _sequencer:
		current_action = _sequencer.get_action()
	
	## If any of above succeeded, open the action (else current_action is null)
	if current_action:
		current_action.action_closed.connect(_on_action_closed)
		current_action.open()

func _on_action_closed() -> void:
	_open_action()
