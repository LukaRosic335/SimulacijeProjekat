extends Node3D


@onready var animation_player: AnimationPlayer = $puska/AnimationPlayer
@onready var muzzle: GPUParticles3D = $muzzleFlash/muzzle

@onready var reloading = false


func reload() -> void:
	animation_player.play("reload")
	await animation_player.animation_finished
	reloading = false


func shoot() -> void:
	animation_player.play("shoot")
	muzzle.emitting = true
	reloading = true
	await animation_player.animation_finished
	reload()
