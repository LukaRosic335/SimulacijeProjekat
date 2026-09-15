extends Node3D


@onready var settings_scene = preload("res://scenes/settings.tscn")


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_main.tscn")


func _on_btn_settings_pressed() -> void:
	add_child(settings_scene.instantiate())


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
