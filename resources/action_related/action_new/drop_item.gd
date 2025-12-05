extends GoToAnd
class_name TryDropItem

@export var drop_anim: String = "PickUpGround"
@export var drop_slot: int = 0     

var _anim_started: bool = false
var _finished: bool = false
var _pending_item_list: Array = []
var _connected: bool = false

func create(character_: Character, where_: Vector2, drop_anim_: String = "Throw") -> TryDropItem:
	super._create(character_, where_)
	drop_anim = drop_anim_
	return self

func open() -> void:
	super()
	_finished = false
	_anim_started = false
	_pending_item_list = []
	_connected = false
	character.velocity = Vector2.ZERO

func update(delta: float) -> void:
	if _subaction:
		super(delta)
		return

	if _anim_started:
		return

	var item_list := character.inventory.get_items()
	if drop_slot >= item_list.size():
		print("[TryDropItem] Brak przedmiotów do wyrzucenia.")
		_complete()
		return

	# przygotuj listę i uruchom animację
	_pending_item_list = item_list.duplicate()
	_start_drop_anim()

func _start_drop_anim() -> void:
	if _anim_started:
		return
	_anim_started = true
	character.velocity = Vector2.ZERO

	if character.animated_sprite_2d:
		if not _connected:
			character.animated_sprite_2d.animation_finished.connect(Callable(self, "_on_animation_finished"))
			_connected = true

	character.animated_sprite_2d.play(drop_anim)

func _on_animation_finished() -> void:
	if not character or character.animated_sprite_2d.animation != drop_anim:
		return

	_on_drop_finished()

func _on_drop_finished() -> void:
	if _finished:
		return
	_finished = true

	var item_list := character.inventory.get_items()
	if drop_slot < item_list.size():
		var dropped_item: Item = item_list[drop_slot]
		character.inventory.drop_item(drop_slot)
		print("[TryDropItem] NPC wyrzucił przedmiot:", dropped_item.name)
	else:
		print("[TryDropItem] Slot był pusty w momencie dropa")

	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")

	_cleanup_connections()
	call_deferred("_complete")

func _cleanup_connections() -> void:
	if _connected and character and character.animated_sprite_2d:
		if character.animated_sprite_2d.animation_finished.is_connected(Callable(self, "_on_animation_finished")):
			character.animated_sprite_2d.animation_finished.disconnect(Callable(self, "_on_animation_finished"))
	_connected = false
	_pending_item_list.clear()
	_anim_started = false

func close() -> void:
	_finished = true
	_cleanup_connections()
	character.velocity = Vector2.ZERO
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play("Idle")
	super()
