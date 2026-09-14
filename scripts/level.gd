class_name Level
extends Node3D


signal spawn_galeb(galeb: Galeb)


func _on_spawn_area_spawn_galeb(galeb: Galeb) -> void:
	spawn_galeb.emit(galeb)
