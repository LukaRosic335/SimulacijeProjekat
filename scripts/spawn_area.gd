class_name SpawnArea
extends Area3D


signal spawn_galeb(galeb: Galeb)


@export var galeb_count: int = 10
@onready var galeb_scene: PackedScene = preload("res://scenes/galeb_2.tscn")


func _ready() -> void:
	spawn_galebs()


func spawn_galebs() -> void:
	var areas = get_children()
	for i in range(0, galeb_count):
		var area = areas[randi_range(0, areas.size() - 1)]
		var box3d = area.shape as BoxShape3D
		var area_size = box3d.size
		var pos = Vector3(
			randf_range(-area_size.x / 2, area_size.x / 2),
			randf_range(-area_size.y / 2, area_size.y / 2),
			randf_range(-area_size.z / 2, area_size.z / 2)
		)
		var galeb = galeb_scene.instantiate()
		add_child(galeb)
		galeb.global_position = area.global_transform * pos
		spawn_galeb.emit(galeb)
