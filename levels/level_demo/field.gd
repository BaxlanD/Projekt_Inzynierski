extends Place
class_name Field

enum state {unwatered, watered, burning, destroyed}
var curr_state: state = state.unwatered
@onready var interactable: Interactable = $Interactable

@export var target_npc_name: String = "NPC_Titus"
@export var required_sequence: String = "titus_action_five"
@export var sequence_to_push: Sequence  
@export var interaction_label := "Do field work"

func _ready() -> void:
	update_visual()
	interactable.interact = _on_interact
	set_meta("_enums", {
		"curr_state": {
			"unwatered": state.unwatered,
			"watered": state.watered,
			"burning": state.burning,
			"destroyed": state.destroyed
		}
	})

func update_visual() -> void:
	var sprite : Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		match curr_state:
			state.unwatered:
				sprite.texture = preload("res://assets/field_unwatered.png")
			state.watered:
				sprite.texture = preload("res://assets/field_watered.png")
			state.burning:
				sprite.texture = preload("res://assets/field_burning.png")
			state.destroyed:
				sprite.texture = preload("res://assets/field_destroyed.png")
				
func set_state(new_state: state) -> void:
	curr_state = new_state
	update_visual()
	
func get_place_interactions(npc: NPCActions) -> Array[Dictionary]:
	var ops: Array[Dictionary] = []

	if npc.name != target_npc_name:
		return ops

	if npc.get_active_sequence_name() == required_sequence:
		ops.append({
			"id": "field_action",
			"name": interaction_label,
			"action": Callable(self, "execute_place_interaction").bind(npc)
		})

	return ops
	
func execute_place_interaction(npc: NPCActions, interaction_id: String = "field_action") -> void:
	if interaction_id != "field_action":
		return

	if not sequence_to_push:
		push_warning("Field has no sequence_to_push assigned.")
		return

	print("[FIELD] Triggering interrupt for:", npc.name)

	var seq_copy : Sequence = sequence_to_push.duplicate(true)
	for act in seq_copy._actions:
		act.character = npc

	npc.sequence_controller.push_instant(seq_copy)
