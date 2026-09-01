extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."

@export var speed:float=100
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("dole"):
		velocity.y=1*speed
	elif Input.is_action_pressed("gore"):
		velocity.y=-1*speed
	elif Input.is_action_pressed("levo"):
		velocity.x=-1*speed
	elif Input.is_action_pressed("desno"):
		velocity.x=1*speed
	else :
		velocity=Vector2.ZERO
	move_and_slide()
