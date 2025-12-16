extends GoToAnd
class_name TryPickup

@export var item: String
@export var search_duration: float = 1.0
@export var retain_to_change: Retain = null

var _anim_started: bool = false
var _finished: bool = false
var _connected: bool = false
var _search_timer: float = 0.0

func create(character_: Character, where_: Vector2, item_: String) -> TryPickup:
	super._create(character_, where_)
	item = item_
	return self

func open() -> void:
	super()
	_finished = false
	_anim_started = false
	_connected = false
	_search_timer = 0.0

func update(delta: float) -> void:
	if _subaction:
		super(delta)
		return
	
	if character.inventory.get_items().size() == character.inventory.max_items:
		print("NPC inventory full.")
		_complete()
		return
		
	if _anim_started:
		return

	var pickup_area := character.interactable
	var found_item := false
	
	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("items") and area is Item:
			var item_area: Item = area as Item 
			found_item = true
			if not _anim_started:
				_start_pickup_anim(item_area)
			break
	
	if found_item:
		_search_timer = 0.0
	else:
		_search_timer += delta
		if _search_timer >= search_duration:
			print("No item found after", search_duration, "seconds — ending TryPickup.")
			_complete()

func _start_pickup_anim(area: Item) -> void:
	_anim_started = true
	character.velocity = Vector2.ZERO
	character.animated_sprite_2d.play("PickUpGround")

	if not _connected:
		character.animated_sprite_2d.animation_finished.connect(
			func() -> void:
				if character.animated_sprite_2d.animation == "PickUpGround" and not _finished:
					_on_pickup_finished(area),
			CONNECT_ONE_SHOT
		)
		_connected = true

func _on_pickup_finished(area: Item) -> void:
	if _finished:
		return
	_finished = true
	_anim_started = false

	var scene := load(area.origin_scene_path) as PackedScene
	if scene:
		var npc_item := scene.instantiate() as Item
		if character.inventory.add_item(npc_item):
			print("NPC picked up item instance")
			area.queue_free()
			if retain_to_change:
				retain_to_change.set_value(1)
	_complete()

func close() -> void:
	if _anim_started or not _finished:
		_anim_started = false
		_finished = false
		_connected = false
		character.animated_sprite_2d.play("Idle")
		character.velocity = Vector2.ZERO
		
		if character.animated_sprite_2d.animation_finished.is_connected(_on_pickup_finished):
			character.animated_sprite_2d.animation_finished.disconnect(_on_pickup_finished)
	
	super()
