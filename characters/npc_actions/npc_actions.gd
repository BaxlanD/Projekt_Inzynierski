extends Character
class_name NPCActions

@export var navigation_layer: NavigationLayer
#@export var anchored_agent: AnchoredAgent # IN CHARACTER
#
#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D # IN CHARACTER
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var npc_floor_level: float = 0
#var current_sequence_index: int = -1 # IN CHARACTER

#@onready var inventory: Inventory = $Inventory # IN CHARACTER
#@onready var interactable: Interactable = $Interactable # IN CHARACTER
@onready var interupt_manager: InteruptManager = InteruptManager.new()

const _SPEED = 120.0
const _JUMP_VELOCITY = -250.0 #unused - npc can't jump

#@onready var sequence_controller: SequenceController = $SequenceController # IN CHARACTER

func _ready() -> void:
	assert(sequence_controller, "NPCActions doesn't have SequenceController asigned")
	anchored_agent.initialize(self)
	sequence_controller.start(self)

func _physics_process(delta: float) -> void:
	if !sequence_controller._started:
		return
	
	npc_floor_level = ray_cast_2d.get_collision_point().y
	
	if Input.is_action_just_pressed("LMB"):
		sequence_controller.push_instant(Sequence.new().with_fleeting().from_actions([
			PlayAnim.new().create(self, get_global_mouse_position(), "Death")
		]))
	
	sequence_controller.update(delta)

func _actor_setup() -> void:
	# Need to wait for physics frame for npc_floor_level to get set for moving
	await get_tree().physics_frame
	sequence_controller.start(self)
	
func on_interaction_started(interaction_type: String) -> void:
	character_stop()
	animated_sprite_2d.play(interaction_type)

func on_interaction_ended() -> void:
	character_stop()
	animated_sprite_2d.play("Idle")

func character_stop() -> void:
	velocity = Vector2.ZERO
	
func can_accept_item(_item: Item) -> bool:
	return false
	
func get_current_sequence_name() -> String:
	if sequence_controller._action_sequencer._stack.size() == 0:
		return ""
	
	var seq_index: int = current_sequence_index
	if seq_index < 0 or seq_index >= sequence_controller._action_sequencer._stack.size():
		return ""
	
	var seq: Sequence = sequence_controller._action_sequencer._stack[seq_index]
	return seq.sequence_name
	
func get_active_sequence_name() -> String:
	var stack := sequence_controller._action_sequencer._stack
	if stack.is_empty():
		return ""
	return stack.back().sequence_name
		
func get_base_interactions() -> Array[Dictionary]:
	var options: Array[Dictionary] = []

	options.append({
		"name": "Talk",
		"action": Callable(self, "talk_with_npc")
	})

	for def in interupt_manager.interupts:
		if def.requires_item:
			continue
		
		if get_active_sequence_name() not in def.allowed_sequences:
			continue

		if interupt_manager.was_triggered(def, name):
			continue

		var seq_name := ""
		if def.sequence:
			seq_name = def.sequence.sequence_name
		elif def.npc_sequences.has(name) and def.npc_sequences[name]:
			seq_name = def.npc_sequences[name].sequence_name
		else:
			seq_name = "Unknown"

		options.append({
			"name": "Interrupt: " + seq_name,
			"action": Callable(self, "_on_trigger_interupt").bind(def)
		})

	return options


func get_item_interactions(item: Item) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	
	var def := interupt_manager.find_for_item(item.get_display_name(), self)
	if def == null:
		return options
		
	options.append({
		"name": "Give " + item.get_display_name(),
		"action": Callable(self, "_on_give_item").bind(item, def)
	})
	return options
	
func talk_with_npc() -> void:
	print("Womp Womp")
	
func _on_give_item(item: Item, def: InteruptDefinition) -> void:
	print("Player gave:", item.get_display_name())

	var player_inv := get_tree().get_root().get_node("LevelDemo/Player/Inventory") as Inventory
	for i in range(player_inv.items.size()):
		if player_inv.items[i].get_display_name() == item.get_display_name():
			player_inv.items[i].queue_free()
			player_inv.remove_item(i)
			break
			
	var me_name := name
	var readyy := interupt_manager.signal_ready(def, me_name)
	if not readyy:
		print("[Interupt] waiting for other participants for", def.sequence.resource_name)
		return

	_execute_interupt_for_def(def)
	
func _on_trigger_interupt(def: InteruptDefinition) -> void:
	if interupt_manager.was_triggered(def, name):
		print("[Interupt] already triggered once for", def.resource_name, "by", name)
		return
		
	var seq_name := def.sequence and def.sequence.resource_name or (def.resource_name if def.resource_name != "" else "Unknown")
	print("Triggered base interrupt:", seq_name)
	interupt_manager._trigger_all_for_def(def)

	
func _find_npc_by_name(_name: String) -> NPCActions:
	var npc: NPCActions = NpcRegistry.get_npc(_name)
	if npc:
		return npc as NPCActions
	return null
	
func _execute_interupt_for_def(def: InteruptDefinition) -> void:
	var targets: Array = []
	if def.linked_npcs and def.linked_npcs.size() > 0:
		targets = def.linked_npcs.duplicate()
	else:
		targets.append(name)

	for target_name: String in targets:
		var target_npc := _find_npc_by_name(target_name)
		if not target_npc:
			print("[Interupt] target npc not found:", target_name)
			continue
			
		var seq_controller := target_npc.sequence_controller
		if not seq_controller or not seq_controller._action_sequencer:
			continue
			
		var sequencer := seq_controller._action_sequencer
		
		var to_skip := int(def.skip_count)
		if to_skip > 0:
			for i in range(to_skip):
				if sequencer._stack.size() > 0:
					sequencer._stack.pop_back()

		var seq_to_use: Sequence = null
		if def.npc_sequences.has(target_name):
			seq_to_use = def.npc_sequences[target_name]
		elif def.sequence:
			seq_to_use = def.sequence
		else:
			print("[Interupt] No sequence defined for", target_name)
			continue

		var seq_copy : Sequence = seq_to_use.duplicate(true)
		if seq_copy.has_method("initialize_with_character"):
			seq_copy.initialize_with_character(target_npc)
		else:
			for act in seq_copy._actions:
				act.character = target_npc

		target_npc.sequence_controller.push_instant(seq_copy)
		print("[Interupt] pushed interrupt to", target_name, "->", seq_copy.sequence_name)
		
func execute_place_interrupt(def: InteruptDefinition) -> void:
	if not def:
		print("[PlaceInterrupt] invalid interrupt definition")
		return

	print("[PlaceInterrupt] Triggering:", def.resource_name)

	if interupt_manager.was_triggered(def, name):
		print("[PlaceInterrupt] already triggered, skipping")
		return

	interupt_manager._trigger_all_for_def(def)
