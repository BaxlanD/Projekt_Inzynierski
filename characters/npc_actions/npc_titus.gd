extends NPCActions
class_name NPC_Titus


func _ready() -> void:
	super()
	NpcRegistry.register_npc("NPC_Titus", self)
	_setup_interupts()
	
func _setup_interupts() -> void:
	var water_jug_def := InteruptDefinition.new()
	water_jug_def.item_name = "Water Jug"
	water_jug_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_water.tres")
	water_jug_def.allowed_sequences = ["Titus_action_one"]
	water_jug_def.skip_count = 1
	interupt_manager.add_interupt(water_jug_def)
	
	var red_coat_def := InteruptDefinition.new()
	red_coat_def.item_name = "Red Coat"
	red_coat_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_coat.tres")
	red_coat_def.allowed_sequences = ["Titus_action_twoAndThree"]
	interupt_manager.add_interupt(red_coat_def)
	
	var comfort_def := InteruptDefinition.new()
	comfort_def.requires_item = false
	comfort_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_comfort.tres")
	comfort_def.allowed_sequences = ["Titus_interupt_coat"]
	comfort_def.trigger_once = true
	comfort_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(comfort_def)
	
	var iron_bars_def := InteruptDefinition.new()
	iron_bars_def.item_name = "Iron Bars"
	iron_bars_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_iron.tres")
	iron_bars_def.allowed_sequences = ["Titus_action_five"]
	interupt_manager.add_interupt(iron_bars_def)
	
	var snitch_def := InteruptDefinition.new()
	snitch_def.requires_item = false
	snitch_def.allowed_sequences = ["Titus_action_four"]
	snitch_def.linked_npcs = ["NPC_Eski", "NPC_Titus"]
	snitch_def.npc_sequences ={"NPC_Eski": preload("res://resources/action_related/action_new/Eski/Interrupts/eski_interrupt_snitch.tres"),
								"NPC_Titus" : preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_snitch.tres")}
								
	snitch_def.skip_count = 1
	snitch_def.participants_required = 2
	snitch_def.trigger_once = true
	interupt_manager.add_interupt(snitch_def)
	
	var afterFight_talk_def := InteruptDefinition.new()
	afterFight_talk_def.requires_item = false
	afterFight_talk_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_beer_talk.tres")
	afterFight_talk_def.allowed_sequences = ["Titus_interrupt_beer"]
	afterFight_talk_def.trigger_once = true
	afterFight_talk_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(afterFight_talk_def)
	
	var mozaic_def := InteruptDefinition.new()
	mozaic_def.item_name = "Mozaic"
	mozaic_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_mozaic_late.tres")
	mozaic_def.allowed_sequences = ["Titus_action_sevenAndEight","Titus_action_nineAndTen", "Titus_interrupt_lookForEski"]
	interupt_manager.add_interupt(mozaic_def)
	
	var confrontation_def := InteruptDefinition.new()
	confrontation_def.item_name = "Mozaic"
	confrontation_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_interrupt_mozaic_early.tres")
	confrontation_def.allowed_sequences = ["Titus_action_six"]
	interupt_manager.add_interupt(confrontation_def)
	
	var get_help_def := InteruptDefinition.new()
	get_help_def.requires_item = false
	get_help_def.sequence = preload("res://resources/action_related/action_new/Titus/Interrupts/titus_get_help.tres")
	get_help_def.allowed_sequences = ["Titus_interrupt_confrontation2"]
	get_help_def.trigger_once = true
	get_help_def.linked_npcs = [self.name]
	interupt_manager.add_interupt(get_help_def)
	
