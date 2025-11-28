extends CharacterBody2D
class_name Character

var current_sequence_index: int = -1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var anchored_agent: AnchoredAgentV2 = $AnchoredAgentV2
@onready var inventory: Inventory = $Inventory
@onready var interactable: Interactable = $Interactable
@onready var sequence_controller: SequenceController = $SequenceController
