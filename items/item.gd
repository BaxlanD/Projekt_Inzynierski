extends Area2D
class_name Item

@export var item_name: String = "item"
@export var origin_scene_path : String = ""
@export var use_special_inventory: bool = false
@export var actor_layer: int = -1
@onready var interactable: Interactable = $Interactable

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
	if origin_scene_path == "":
		initialize()
	print("origin_scene_path set to: ", origin_scene_path)
	interactable.interact = _on_interact

func is_same_as(path: String) -> bool:
	return origin_scene_path == path
	
func use() -> void:
	print("Item used")
	
func _on_interact() -> void:
		var inv : Inventory
		if use_special_inventory:
			inv = get_tree().get_root().get_node("LevelVillage/Player/SpecialInventory") as Inventory
		else:
			inv = get_tree().get_root().get_node("LevelVillage/Player/Inventory") as Inventory
		var scene := load(origin_scene_path) as PackedScene
		if scene:
			var new_item := scene.instantiate()
			var item_script := new_item as Item
			if item_script and inv.add_item(item_script):
				queue_free()
