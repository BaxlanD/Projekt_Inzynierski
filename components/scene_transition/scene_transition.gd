extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func change_scene(new_scene: String) -> void:
	print_rich("[color=yellow]%s[/color]" % new_scene)
	
	visible = true
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(new_scene)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("RMB"):
		audio_stream_player.play()
