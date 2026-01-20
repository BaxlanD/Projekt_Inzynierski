extends Node2D
class_name Level

@onready var navigator: Navigator = $Navigator
@onready var npcs: Node = $NPCs
@onready var items: Node = $Items

func _process(delta: float) -> void:
	if Input.is_action_pressed("reset"):
		queue_free()
		reset.call_deferred()

func reset() -> void:
	SceneTransition.change_scene("res://levels/level-village/level_village.tscn")

func set_active_layer(layer_index: int) -> void:
	for i in navigator.get_child_count():
		var layer : LevelLayer = navigator.get_child(i)
		layer.modulate.a = 1.0 if i == layer_index else 0.0
		layer.visible = i == layer_index
	for i in npcs.get_child_count():
		var npc : NPCActions = npcs.get_child(i)
		var npc_agent : AnchoredAgentV2 = npc.get_node("AnchoredAgentV2")
		npc.modulate.a = 1.0 if npc_agent.actor_layer == layer_index else 0.0
		npc.visible = i == layer_index
	for i in items.get_child_count():
		var item : Item = items.get_child(i)
		item.modulate.a = 1.0 if item.actor_layer == layer_index else 0.0
		item.visible = i == layer_index
