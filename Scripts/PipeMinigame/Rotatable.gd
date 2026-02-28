extends Sprite2D


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_mouse_over():
			if event.button_index == MOUSE_BUTTON_LEFT:
				rotation_degrees += 90
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				rotation_degrees -= 90

func is_mouse_over():
	var local_mouse = to_local(get_global_mouse_position())
	return get_rect().has_point(local_mouse)
