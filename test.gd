extends Node2D

@onready var schedule_npc: ScheduleNPC = $ScheduleNPC

var action: Action

func _ready() -> void:
	schedule_npc.new_shedule_entry_started.connect(callback_schedule)
	schedule_npc.start_schedule()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("RMB"):
		if action:
			action.cancel()
		action = StandAtPointAction.new(self, get_global_mouse_position(), 0.8, Action.anchor.OVERRIDE)
		action.action_finished.connect(callback_finished)
	
	if action:
		action.update(delta)

func callback_finished() -> void:
	print("Callback_Finished")
	# Overriding action finished - get back to scheduled action
	action = StandAtPointAction.new(self, schedule_npc.get_current_target(), 1, Action.anchor.SCHEDULE)
	action.action_finished.connect(callback_finished)

func callback_schedule(target: Vector2) -> void:
	# Time for new scheduled action
	# Override if currently has no action or doing scheduled action
	# Don't override if currently doing overriding action (it will fetch schedule when it ends)
	if action == null or action.type == Action.anchor.SCHEDULE:
		print("Schedule callback success")
		action = StandAtPointAction.new(self, target, 1, Action.anchor.SCHEDULE)
		action.action_finished.connect(callback_finished)
	else:
		print("Schedule callback fail")
