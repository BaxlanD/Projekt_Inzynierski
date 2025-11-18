extends NPCActions
class_name NPC_Eski

func _ready() -> void:
	super()
	NpcRegistry.register_npc("NPC_Eski", self)
	_setup_interupts()

func _setup_interupts() -> void:
	var broom_def := InteruptDefinition.new()
	broom_def.item_name = "Broom"
	broom_def.sequence = preload("res://resources/action_related/action_new/Eski/Interrupts/eski_interrupt_broom.tres")
	broom_def.allowed_sequences = ["Eski_action_one"]
	interupt_manager.add_interupt(broom_def)
	
	var gold_coins_def := InteruptDefinition.new()
	gold_coins_def.item_name = "Coins"
	gold_coins_def.sequence = preload("res://resources/action_related/action_new/Eski/Interrupts/eski_interrupt_confrontation.tres")
	gold_coins_def.allowed_sequences = ["Eski_action_twelve"]
	interupt_manager.add_interupt(gold_coins_def)
	
	var mozaic_dead_def := InteruptDefinition.new()
	mozaic_dead_def.item_name = "Mozaic"
	mozaic_dead_def.sequence = preload("res://resources/action_related/action_new/Eski/Interrupts/eski_ending4.tres")
	mozaic_dead_def.allowed_sequences = ["Eski_action_seventeen"]
	mozaic_dead_def.skip_count = 2
	interupt_manager.add_interupt(mozaic_dead_def)
	
	var mozaic_early_def := InteruptDefinition.new()
	mozaic_early_def.item_name = "Mozaic"
	mozaic_early_def.sequence = preload("res://resources/action_related/action_new/Eski/Interrupts/eski_interrupt_mozaic_early.tres")
	mozaic_early_def.allowed_sequences = ["Eski_action_one", "Eski_action_two"]
	interupt_manager.add_interupt(mozaic_early_def)
	
	var eski_letter_def := InteruptDefinition.new()
	eski_letter_def.item_name = "Eski Letter"
	eski_letter_def.sequence = preload("res://resources/action_related/action_new/Eski/Interrupts/eski_interrupt_letter.tres")
	eski_letter_def.allowed_sequences = ["Eski_action_one","Eski_action_two","Eski_action_three"]
	interupt_manager.add_interupt(eski_letter_def)

	
