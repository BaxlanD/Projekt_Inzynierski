extends Area2D

@export var item_name: String = "item"
var player_in_range: bool = false

func _ready():
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)
	print(player_in_range)
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		print(player_in_range)

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false
		
func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("item_take"):
		var inv := get_tree().get_root().get_node("LevelDemo/UI/InventoryUI") as Control
		if inv.has_method("add_item"):
			if inv.add_item(item_name):
				queue_free()
