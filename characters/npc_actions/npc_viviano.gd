extends NPCActions
class_name NPC_Viviano

func _ready() -> void:
	super()
	NpcRegistry.register_npc("NPC_Viviano", self)
	_setup_interupts()
	
func _setup_interupts() -> void:
	
	var tint_def := InteruptDefinition.new()
	tint_def.item_name = "Tint"
	tint_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/viviano_interrupt_tint.tres")
	tint_def.allowed_sequences = ["Viviano_idle"]
	interupt_manager.add_interupt(tint_def)
