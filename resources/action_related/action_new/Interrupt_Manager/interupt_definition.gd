extends Resource
class_name InteruptDefinition

@export var trigger_once: bool = false

@export var item_name: String
@export var requires_item: bool = true

@export var sequence: Sequence
@export var npc_sequences: Dictionary = {}

@export var allowed_sequences: Array[String] = []
@export var skip_count: int = 0

@export var linked_npcs: Array[String] = []
@export var participants_required: int = 1
