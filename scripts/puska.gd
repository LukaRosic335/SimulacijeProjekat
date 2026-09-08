extends Node3D


@onready var animation_player: AnimationPlayer = $puska/AnimationPlayer

@onready var reloading = false


func reload() -> void:
	reloading = true
	animation_player.play("reload")
	await animation_player.animation_finished
	reloading = false


func shoot() -> void:
	animation_player.play("shoot")
	await animation_player.animation_finished
	reload()
