class_name GalebEksplozija
extends Node3D


signal finished


@onready var krv: GPUParticles3D = $krv
@onready var perje: GPUParticles3D = $perje
@onready var perje_2: GPUParticles3D = $perje2


func explode() -> void:
	krv.emitting = true
	perje.emitting = true
	perje_2.emitting = true


func _on_krv_finished() -> void:
	finished.emit()


func _on_perje_finished() -> void:
	finished.emit()


func _on_perje_2_finished() -> void:
	finished.emit()
