class_name GalebEksplozija
extends Node3D


@onready var krv: GPUParticles3D = $krv
@onready var perje: GPUParticles3D = $perje
@onready var perje_2: GPUParticles3D = $perje2


func explode() -> void:
	krv.emitting = true
	perje.emitting = true
	perje_2.emitting = true
