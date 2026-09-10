class_name GalebEksplozija
extends Node3D


@onready var krv: GPUParticles3D = $krv
@onready var perje: GPUParticles3D = $perje


func explode() -> void:
	krv.emitting = false
	krv.emitting = true
	perje.emitting = false
	perje.emitting = true
