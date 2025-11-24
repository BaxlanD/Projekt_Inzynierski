extends Action
class_name PartnerAnim

@export var anim_name: String = "Talk"
@export var duration: float = 3.0
var _timer: float = 0.0

func create(character_: Character, anim_name_: String = "Talk", duration_: float = 3.0) -> PartnerAnim:
	character = character_
	anim_name = anim_name_
	duration = duration_
	return self

func open() -> void:
	_timer = duration
	if character.animated_sprite_2d:
		character.animated_sprite_2d.play(anim_name)
	print("%s started %s animation" % [character.name, anim_name])

func update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		if character.animated_sprite_2d:
			character.animated_sprite_2d.play("Idle")
		_complete()
