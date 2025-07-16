extends GoToAnd
class_name PlayAnim

@export var animation: String
var _anim_started: bool = false

func create(character_: NPCActions, where_: Vector2, animation_: String) -> PlayAnim:
	# Call to super _create() because GDScript doesn't have argument overloading
	# This handles GoTo 'subaction'
	super._create(character_, where_)
	# -> Initialize your own stuff below
	animation = animation_
	return self

func open() -> void:
	# Call to super open() which opens up subaction
	super()
	# -> Initialize your own stuff below
	pass

func update(delta: float) -> void:
	# If subaction is active, just call super and return
	if _subaction:
		super(delta)
		return
	
	# -> Here handle your own update loop - will execute AFTER subaction finishes
	if not _anim_started:
		_anim_started = true
		character.animated_sprite_2d.play(animation)
		character.animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func close() -> void:
	# -> Handle any cleanup for your action here
	# Call super close() AFTER, which will make subaction emit closed signal to controller
	super()

func _on_animation_finished() -> void:
	_complete()
