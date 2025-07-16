extends ActionV1
class_name ReactAtPointAction

@export var target_position: Vector2
@export var anim_duration: float = 2.0
#@export var anim_name_1 := ""
#@export var anim_name_2 := ""

var current_subaction: ActionV1
var _elapsed_time := 0.0
var _anim_started := false
var animation_name := ""
var _was_comforted := false

func create(character_: CharacterBody2D, target_: Vector2, duration_: float) -> ReactAtPointAction:
	character = character_
	target_position = target_
	anim_duration = duration_
	animation_name = "Death" if character.bad_day > 0 else "PickUpGround"
	_start()
	return self

func copy() -> ReactAtPointAction:
	return ReactAtPointAction.new().create(character, target_position, anim_duration)

func update(delta: float) -> void:
	if current_subaction:
		current_subaction.update(delta)
		return

	_elapsed_time += delta
	if _anim_started:
		_elapsed_time += delta
		if _elapsed_time >= anim_duration:
			_finish()

func cancel() -> void:
	if current_subaction:
		current_subaction.cancel()
	_cleanup()
	
func _start() -> void:
	current_subaction = AnimateAtPointAction.new().create(character, type, target_position, animation_name)
	current_subaction.action_finished.connect(_on_animate_ready)
	
func _on_animate_ready() -> void:
	current_subaction = null
	character.animated_sprite_2d.play(animation_name)
	_anim_started = true
	_elapsed_time = 0.0
	character.animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished() -> void:
	if _anim_started:
		character.animated_sprite_2d.play(animation_name)
	
func _cleanup() -> void:
	current_subaction = null

func _finish() -> void:
	_cleanup()
	action_finished.emit()
	
func comfort() -> void:
	if _was_comforted:
		print("Already comforted.")
		return
	if character.bad_day <= 0:
		print("NPC doesn't need comforting.")
		return

	_was_comforted = true
	print("NPC comforted — skipping animation.")
	
	if character.animated_sprite_2d.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		character.animated_sprite_2d.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

	character.animated_sprite_2d.play("Idle")
	_finish()
