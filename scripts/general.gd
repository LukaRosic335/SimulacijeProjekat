extends Node


var fullscreen : bool = false


func _ready() -> void:
	Engine.max_fps = 60


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
