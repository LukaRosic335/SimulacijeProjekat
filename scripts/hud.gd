extends Control

@onready var interaction_ray: RayCast3D = $"../head/Camera3D/InteractionRay"
@onready var crosshair: TextureRect = $crosshair
@onready var camera_3d: Camera3D = $"../head/Camera3D"

@onready var general = preload("res://assets/crosshairs/general.png")
@onready var interact = preload("res://assets/crosshairs/interact.png")
@onready var screen = preload("res://assets/crosshairs/screen.png")
@onready var service = preload("res://assets/crosshairs/service.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target = interaction_ray.__find_target()
	if target == null:
		crosshair.texture = general
		return
	if target.is_in_group("Pickable"):
		crosshair.texture = interact
	else:
		crosshair.texture = general
