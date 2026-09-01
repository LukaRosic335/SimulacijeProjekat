extends Control

@onready var interaction_ray: RayCast3D = $"../Camera3D/InteractionRay"
@onready var crosshair: TextureRect = $crosshair

@onready var general = preload("res://assets/crosshairs/general.png")
@onready var interact = preload("res://assets/crosshairs/interact.png")
@onready var screen = preload("res://assets/crosshairs/screen.png")
@onready var service = preload("res://assets/crosshairs/service.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not interaction_ray.is_colliding():
		crosshair.texture = general
	
	var intersection = interaction_ray.get_collider()
	if not intersection:
		return
	var target = intersection.get_parent()
	if target.is_in_group("Pickable"):
		crosshair.texture = interact
		return
	if target.is_in_group("Serviceable"):
		crosshair.texture = service
		return
	if target.is_in_group("Minigame"):
		crosshair.texture = screen
		return
