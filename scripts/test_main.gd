extends Node3D


var fullscreen : bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true


func _on_player_drop_item(item: Node3D, force: Vector3) -> void:
	item.reparent(self)
	if item.is_in_group("Galeb"):
		if force == Vector3.ZERO:
			if not item.dead:
				item.set_dropped()
			else:
				item.set_thrown(force)
				print("GALEB DROP")
		else:
			item.set_thrown(force)
			print("GALEB THROW")
	if item.is_in_group("Item"):
		item.freeze = false
		item.apply_impulse(force, item.global_position)
		item.apply_force(force / 4, item.global_position)
	print("Item dropped") # DEBUG
