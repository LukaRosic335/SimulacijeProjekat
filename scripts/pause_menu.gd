extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_btn_resume_pressed() -> void:
	get_parent().unpause()


func _on_btn_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_btn_quit_game_pressed() -> void:
	get_tree().quit()
