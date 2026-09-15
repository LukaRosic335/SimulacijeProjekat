class_name Mlevilica
extends Node3D

@onready var animation_player: AnimationPlayer = $MlevilicaPastetarnik7259tm/AnimationPlayer
@onready var koralovo_uredjaj_ulaz: Area3D = $KoralovoUredjajUlaz

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var MLEVILICA = preload("uid://bak6j2b40dvy")

@onready var pasteta_scene = preload("res://scenes/pasteta.tscn")
@onready var pasteta_drop_point: Node3D = $PastetaDropPoint
@onready var pasteta_niz_cev: AudioStreamPlayer3D = $"pasteta-niz-cev"


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
	pasteta_niz_cev.play()
	# sacekaj kraj animacije
	# izbaci pastetu
	await get_tree().create_timer(1).timeout
	var pasteta: Pasteta = pasteta_scene.instantiate()
	add_child(pasteta)
	pasteta.global_position = pasteta_drop_point.global_position
	pasteta.rotation_degrees.x = randf_range(-70,70)
	pasteta.rotation_degrees.y = randf_range(-180,180)
	pasteta.rotation_degrees.z = randf_range(-70,70)
	pass


func _ready() -> void:
	animation_player.play("Mlevenje")
	MLEVILICA.loop = true
	audio_stream_player_3d.stream = MLEVILICA
	audio_stream_player_3d.play()
