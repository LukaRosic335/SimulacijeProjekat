class_name Puska
extends Node3D


@onready var animation_player: AnimationPlayer = $puska/AnimationPlayer
@onready var muzzle: GPUParticles3D = $muzzleFlash/muzzle

@onready var reloading = false

const GUN_KNOCKBACK = 1.0
@export var pelet_count = 48

@onready var shoot_sfx: AudioStreamPlayer3D = $shoot_sfx
@onready var reload_sfx: AudioStreamPlayer3D = $reload_sfx


func reload() -> void:
	animation_player.play("reload")
	reload_sfx.play()
	await animation_player.animation_finished
	reloading = false


func shoot(raycast: ShotgunRaycast, vector: Vector3) -> void:
	animation_player.play("shoot")
	shoot_sfx.play()
	muzzle.emitting = true
	reloading = true
	for i in pelet_count:
		var target = raycast.get_target()
		if target != null and target.is_in_group("Galeb"):
			var galeb: Galeb = target
			galeb.kill(vector * GUN_KNOCKBACK)
	await animation_player.animation_finished
	reload()
