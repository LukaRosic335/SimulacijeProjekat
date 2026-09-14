class_name Mlevilica
extends Node3D

@onready var koralovo_uredjaj_ulaz: Area3D = $KoralovoUredjajUlaz

@onready var pasteta_scene = preload("res://scenes/pasteta.tscn")
@onready var pasteta_drop_point: Node3D = $PastetaDropPoint


var samleveni_galebovi: int = 0


func _on_koralovo_uredjaj_ulaz_area_entered(area: Area3D) -> void:
	var body = area.get_parent()
	if body is Galeb:
		body.frickin_explode(self)
	samelji_galeba()


func samelji_galeba() -> void:
	# pusti animaciju
	# pusti zvuk
	# sacekaj kraj animacije
	samleveni_galebovi += 1
	# azuriraj prikaz
	if samleveni_galebovi == 4:
		izbaci_pastetu()


func izbaci_pastetu() -> void:
	# pusti animaciju
	# pusti zvuk
	# sacekaj kraj animacije
	# izbaci pastetu
	var pasteta: Pasteta = pasteta_scene.instantiate()
	add_child(pasteta)
	pasteta.global_position = pasteta_drop_point.global_position
	pasteta.rotation_degrees.x = randf_range(-30,30)
	pasteta.rotation_degrees.z = randf_range(-30,30)
	pass
