extends CharacterBody3D


signal drop_item(item : Node3D, item_position : Vector3, force : Vector3)


@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
@onready var interaction_ray: RayCast3D = $head/InteractionRay
@onready var puska: Node3D = $head/puska

@onready var _g_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var _g_const: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var _walk_speed: float = 3
@export var _air_speed: float = 2
@export var _walk_smoothing: float = 0.35
@export var _air_smoothing: float = 0.12
@export var _sprint_multiplier: float = 2
@export var _jump_height: float = 0.5
@export var _mouse_sensitivity: float = 0.05

@onready var _vxz: Vector3 = Vector3.ZERO
@onready var _do_jump: bool = false
@onready var _is_sprinting: bool = false
@onready var _allow_movement: bool = true

# head bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.05
var t_bob = 0.0

const GALEB_THROW_FORCE_MULTIPLIER = 1.5


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func __get_look_vector():
	var v = -head.basis.z
	return Vector3(v.x, 0, v.z)


func _process(_delta: float) -> void:
	if Input.is_action_just_released("quit"):
		get_tree().quit(0)
	
	var res_dir = Vector3.ZERO
	
	if Input.is_action_just_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_allow_movement = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_allow_movement = true
	
	# interact
	if Input.is_action_just_pressed("interact"):
		interaction_ray.interact()
	
	if Input.is_action_just_pressed("drop_item"):
		interaction_ray.drop(Vector3.ZERO)
	
	# movement
	if _allow_movement:
		if Input.is_action_just_pressed("jump") && is_on_floor():
			_do_jump = true
		
		if Input.is_action_just_pressed("left_click"):
			if !puska.reloading:
				puska.shoot()
				
		if Input.is_action_just_released("right_click"):
			interaction_ray.drop(-head.basis.z * GALEB_THROW_FORCE_MULTIPLIER)
		
		var forward = __get_look_vector()
		var right = forward.cross(Vector3.UP)
		var move_dirs = {
			"move_forward":forward,
			"move_back":-forward,
			"move_left":-right, 
			"move_right":right
			}
		
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
		var rot = head.rotation_degrees + Vector3(
			-event.screen_relative.y * _mouse_sensitivity, 
			-event.screen_relative.x * _mouse_sensitivity, 
			0)
		rot.x = clampf(rot.x, -89, 89)
		head.rotation_degrees = rot

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
	
	# head bob
	if is_on_floor():
		t_bob += delta * velocity.length()
	else:
		t_bob += delta * velocity.length() * 0.5
	camera_3d.transform.origin = _headbob(t_bob)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
