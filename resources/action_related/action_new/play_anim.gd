extends GoToAnd
class_name PlayAnim

@export var animation: String
@export var duration: float = 3.0

var _anim_started: bool = false
var _timer: float = 0.0


func create(character_: NPCActions, where_: Vector2, animation_: String,  duration_: float = 3.0) -> PlayAnim:
	# Call to super _create() because GDScript doesn't have argument overloading
	# This handles GoTo 'subaction'
	super._create(character_, where_)
	# -> Initialize your own stuff below
	animation = animation_
	duration = duration_
	return self

func open() -> void:
	# Call to super open() which opens up subaction
	super()
	# -> Initialize your own stuff below
	_anim_started = false
	_timer = 0.0
	pass

func update(delta: float) -> void:
	_check_timeout()
	# If subaction is active, just call super and return
	if _subaction:
		super(delta)
		return
	
	# -> Here handle your own update loop - will execute AFTER subaction finishes
	if not _anim_started:
		_anim_started = true
		character.animated_sprite_2d.play(animation)
		_timer = duration
	
	if _anim_started:
		_timer -= delta
		if _timer <= 0.0:
			_complete()

func close() -> void:
	# -> Handle any cleanup for your action here
	# Call super close() AFTER, which will make subaction emit closed signal to controller
	character.animated_sprite_2d.play("Idle")
	super()

func _on_animation_finished() -> void:
	_complete()
