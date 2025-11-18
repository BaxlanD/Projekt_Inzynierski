extends NPCActions
class_name NPC_Grelda

var _target_position: Vector2 = Vector2.ZERO
var _is_activated: bool = false
var _play_anim_action: PlayAnim = null
var offset_distance: float = 20.0

func _ready() -> void:
	super()
	NpcRegistry.register_npc("Grelda", self)

func activate_for_lawbreaking(target_pos: Vector2) -> void:
	if _is_activated:
		return 
		
	var direction_to_villain: Vector2 = (target_pos - self.global_position).normalized()
		
	
	_is_activated = true
	_target_position = target_pos - direction_to_villain * offset_distance
	
	var action := PlayAnim.new().create(self, _target_position, "Talk", 15.0)
	action.action_closed.connect(_on_action_finished)
	
	sequence_controller.push_instant(
		Sequence.new().with_fleeting().from_actions([action])
	)
	
func _on_action_finished() -> void:
	_is_activated = false
	_play_anim_action = null
	animated_sprite_2d.play("Idle")
