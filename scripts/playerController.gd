extends CharacterBody3D

signal drop_item(item : Node3D, item_position : Vector3, force : Vector3)

@onready var camera_3d: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
#@onready var pistolj: Node3D = $Camera3D/pistolj

@onready var is_drawing: bool = false


@onready var _g_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var _g_const: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var _walk_speed: float = 3
@export var _air_speed: float = 2
@export var _walk_smoothing: float = 0.35
@export var _air_smoothing: float = 0.12
@export var _sprint_multiplier: float = 2
@export var _jump_height: float = 0.5
@export var _mouse_sensitivity: float = 0.3

@onready var _vxz: Vector3 = Vector3.ZERO
@onready var _do_jump: bool = false
@onready var _is_sprinting: bool = false
@onready var _allow_movement: bool = true

@onready var _gun_holstered: bool = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func __get_look_vector():
	var v = -camera_3d.basis.z
	return Vector3(v.x, 0, v.z)

func __has_no_active_fixings():
	return (interaction_ray.target_serviceable == null)

func __permit_movement():
	_allow_movement = !is_drawing && __has_no_active_fixings()

func _process(_delta: float) -> void:
	# OBAVEZNO PRVO U FUNCKIJI
	__permit_movement()
	
	if Input.is_action_just_released("quit"):
		get_tree().quit(0)
	#if __has_no_active_fixings() && Input.is_action_just_pressed("toggle_mouse"):
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#is_drawing = true
		#else:
				#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				#is_drawing = false
	
	var res_dir = Vector3.ZERO
	
	# interact
	if !is_drawing:
		if Input.is_action_just_pressed("interact"):
			interaction_ray.interact()
		
		if Input.is_action_just_released("interact"):
			interaction_ray.uninteract()
		
		if Input.is_action_just_pressed("drop_item"):
			interaction_ray.drop(Vector3.ZERO)
		
		# GUN
		#if Input.is_action_just_pressed("gun"):
			#if _gun_holstered:
				#pull_out()
			#else:
				#holster()
	
	# movement
	if _allow_movement:
		if Input.is_action_just_pressed("jump") && is_on_floor():
			_do_jump = true
		
		if Input.is_action_just_pressed("left_click"):
			interaction_ray.drop(-camera_3d.basis.z * 8)
			interaction_ray.minigame_input("left_click")
				
		
		var forward = __get_look_vector()
		var right = forward.cross(Vector3.UP)
		var move_dirs = {"move_forward":forward,
			"move_back":-forward,
			"move_left":-right, 
			"move_right":right}
			
		for d in move_dirs:
			if (Input.is_action_pressed(d)):
				res_dir += move_dirs[d]
		
		if (Input.is_action_pressed("move_forward")
			&& !Input.is_action_pressed("move_back") 
			&& Input.is_action_pressed("sprint")):
				_is_sprinting = true
		else:
				_is_sprinting = false
	
	_vxz = res_dir.normalized()

func _input(event) -> void:
	if _allow_movement && event is InputEventMouseMotion:
		var rot = camera_3d.rotation_degrees + Vector3(
			-event.screen_relative.y * _mouse_sensitivity, 
			-event.screen_relative.x * _mouse_sensitivity, 
			0)
		rot.x = clampf(rot.x, -89, 89)
		camera_3d.rotation_degrees = rot

func _physics_process(delta: float) -> void:
	# jump
	var vy = Vector3.ZERO
	var on_floor = is_on_floor()
	if (!on_floor):
		vy = Vector3(0,get_real_velocity().y,0) + _g_vector*_g_const*delta
	if (on_floor&& _do_jump):
		vy = -_g_vector*sqrt(2*_g_const*_jump_height)
		_do_jump = false
	
	# walk
	var res_vxz = _vxz
	if on_floor:
		res_vxz *= _walk_speed
	else:
		res_vxz *= _air_speed
	
	if _is_sprinting:
		res_vxz *= _sprint_multiplier
	
	var prev_vxz = Vector3(velocity.x, 0, velocity.z)
	var smooth_coef = _walk_smoothing
	if (!on_floor):
		smooth_coef = _air_smoothing
	
	res_vxz = prev_vxz.cubic_interpolate(res_vxz, prev_vxz, res_vxz, smooth_coef)
	
	# end calculation
	velocity = res_vxz + vy
	move_and_slide()

#func holster():
	#_gun_holstered = true
	#pistolj.hide()

#func pull_out():
	#if interaction_ray.item != null:
		#interaction_ray.drop(Vector3.ZERO)
	#_gun_holstered = false
	#pistolj.show()

#func is_holstered() -> bool:
	#return _gun_holstered
