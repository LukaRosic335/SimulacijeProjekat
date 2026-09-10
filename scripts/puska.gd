class_name Puska
extends Node3D


@onready var animation_player: AnimationPlayer = $puska/AnimationPlayer
@onready var muzzle: GPUParticles3D = $muzzleFlash/muzzle

@onready var reloading = false

const GUN_KNOCKBACK = 1.0


func reload() -> void:
	animation_player.play("reload")
	await animation_player.animation_finished
	reloading = false


func shoot(target: Node, vector: Vector3) -> void:
	animation_player.play("shoot")
	muzzle.emitting = true
	reloading = true
	if target != null and target.is_in_group("Galeb"):
		var galeb: Galeb = target
		galeb.kill(vector * GUN_KNOCKBACK)
	await animation_player.animation_finished
	reload()
