class_name SpawnArea
extends Area3D


@export var galeb_count: int = 7
@onready var galeb_scene: PackedScene = preload("res://scenes/galeb_2.tscn")


func spawn_galebs() -> void:
	for i in range(0, galeb_count):
		var galeb = galeb_scene.instantiate()
		# TODO ranzomizacija pozicija nije prioritet trenutno
