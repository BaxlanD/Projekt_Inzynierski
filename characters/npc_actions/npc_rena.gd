extends NPCActions
class_name NPC_Rena

func _ready() -> void:
	super()
	NpcRegistry.register_npc("NPC_Rena", self)
	_setup_interupts()
	
func _setup_interupts() -> void:
	
	var herbs_def := InteruptDefinition.new()
	herbs_def.item_name = "Herbs"
	herbs_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_herbs.tres")
	herbs_def.allowed_sequences = ["Rena_action_one"]
	interupt_manager.add_interupt(herbs_def)
	
	var notes_def := InteruptDefinition.new()
	notes_def.item_name = "Translated Notes"
	notes_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_notes.tres")
	notes_def.allowed_sequences = ["Rena_interrupt_no_potion"]
	interupt_manager.add_interupt(notes_def)
	
	var prix_def := InteruptDefinition.new()
	prix_def.item_name = "Prix Mushroom"
	prix_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_prix.tres")
	prix_def.allowed_sequences = ["Rena_action_eight"]
	interupt_manager.add_interupt(prix_def)
	
	var apron_def := InteruptDefinition.new()
	apron_def.item_name = "Meropi's Apron"
	apron_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_apron.tres")
	apron_def.allowed_sequences = ["Rena_action_one","Rena_action_two","Rena_action_three","Rena_action_fourAndfive",
	"Rena_action_six","Rena_action_seven","Rena_action_eight", "Rena_action_nine", "Rena_action_ten", "Rena_action_eleven"]
	interupt_manager.add_interupt(apron_def)
	
	var loyal_client_def := InteruptDefinition.new()
	loyal_client_def.requires_item = false
	loyal_client_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_client.tres")
	loyal_client_def.allowed_sequences = ["Rena_action_six"]
	loyal_client_def.trigger_once = true
	loyal_client_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(loyal_client_def)
	
	var chase_help_tint_def := InteruptDefinition.new()
	chase_help_tint_def.requires_item = false
	chase_help_tint_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_chase_help_tint.tres")
	chase_help_tint_def.allowed_sequences = ["Rena_action_ten"]
	chase_help_tint_def.trigger_once = true
	chase_help_tint_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(chase_help_tint_def)
	
	var chase_help_rena_def := InteruptDefinition.new()
	chase_help_rena_def.requires_item = false
	chase_help_rena_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_chase_help_rena.tres")
	chase_help_rena_def.allowed_sequences = ["Rena_action_ten"]
	chase_help_rena_def.trigger_once = true
	chase_help_rena_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(chase_help_rena_def)
	
	var confront_rena_def := InteruptDefinition.new()
	confront_rena_def.requires_item = false
	confront_rena_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_confrontation.tres")
	confront_rena_def.allowed_sequences = ["Rena_action_fifteen"]
	confront_rena_def.trigger_once = true
	confront_rena_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(confront_rena_def)
	
	var blood_def := InteruptDefinition.new()
	blood_def.item_name = "Basikryllos' Blood"
	blood_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_interrupt_blood.tres")
	blood_def.allowed_sequences = ["Rena_action_seven","Rena_action_eight", "Rena_action_nine", "Rena_action_ten", "Rena_action_eleven",
	"Rena_action_twelve"]
	interupt_manager.add_interupt(blood_def)
	
	var get_help_def := InteruptDefinition.new()
	get_help_def.requires_item = false
	get_help_def.sequence = preload("res://resources/action_related/action_new/Rena/Interrupts/rena_get_help.tres")
	get_help_def.allowed_sequences = ["Rena_ending5", "Rena_ending6"]
	get_help_def.trigger_once = true
	get_help_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(get_help_def)
