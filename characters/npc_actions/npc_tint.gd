extends NPCActions
class_name NPC_Tint

func _ready() -> void:
	super()
	NpcRegistry.register_npc("NPC_Tint", self)
	_setup_interupts()
	
func _setup_interupts() -> void:
	
	var kidnap_def := InteruptDefinition.new()
	kidnap_def.requires_item = false
	kidnap_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/tint_interrupt_kidnap.tres")
	kidnap_def.allowed_sequences = ["Tint_idle"]
	kidnap_def.trigger_once = true
	kidnap_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(kidnap_def)
	
	var help_def := InteruptDefinition.new()
	help_def.item_name = "Healing Scroll"
	help_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/tint_interrupt_help.tres")
	help_def.allowed_sequences = ["Tint_sleep"]
	help_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(help_def)
