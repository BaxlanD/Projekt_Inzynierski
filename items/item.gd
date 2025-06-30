extends Area2D
class_name Item

@export var item_name: String = "item"
@export var dropoff_position: Vector2 = Vector2(100, 100)
var player_in_range: bool = false
@export var origin_scene_path : String = ""
var consumable: bool = false

func get_display_name() -> String:
	return "Item"

func get_icon() -> Texture:
	return preload("res://assets/icon.svg")
	
func initialize() -> void:
	if origin_scene_path == "":
		var packed_scene : String = str(get_script().resource_path).replace(".gd", ".tscn")
		if ResourceLoader.exists(packed_scene):
			origin_scene_path = packed_scene

func _ready() -> void:
	connect("body_entered", self._on_body_entered)
	connect("body_exited", self._on_body_exited)
	if origin_scene_path == "":
		initialize()
	print("origin_scene_path set to: ", origin_scene_path)
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		print(player_in_range)

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false
		
func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("item_take"):
		var inv := get_tree().get_root().get_node("LevelDemo/Player/Inventory") as Inventory
		if inv.add_item(self):
			queue_free()
				
func get_dropoff_position() -> Vector2:
	return dropoff_position
	
func use() -> void:
	print("Item used")
