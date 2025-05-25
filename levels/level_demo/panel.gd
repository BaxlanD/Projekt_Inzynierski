extends Panel

func _input(event):
	if event.is_action_pressed("inv"):
		visible = !visible
