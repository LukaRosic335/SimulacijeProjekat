extends Node3D


@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		pause()


func pause() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.show()


func unpause() -> void:
	pause_menu.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	pass


func _on_player_drop_item(item: Node3D, force: Vector3) -> void:
	item.reparent(self)
	if item.is_in_group("Galeb"):
		if force.length() <= 1:
			if not item.dead:
				item.set_dropped(force)
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


func _on_test_level_spawn_galeb(galeb: Galeb) -> void:
	galeb.reparent.call_deferred(self, true)
