extends Node3D


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_main.tscn")


func _on_btn_settings_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
