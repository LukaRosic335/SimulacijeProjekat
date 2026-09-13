class_name Galeb
extends CharacterBody3D

@export_enum("T_Pose", "Idle", "Peck_Floor", "Peck_Wall", "Flying", "Walking", "Struggle") var starting_animation : String = "T_Pose"

@onready var animation_player: AnimationPlayer = $galeb2/AnimationPlayer
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var physical_bone: PhysicalBone3D = $"galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Telo"
@onready var galeb_eksplozija = preload("res://scenes/galeb_eksplozija.tscn")
@onready var scare_area: Area3D = $ScareArea
@onready var wall_check: RayCast3D = $WallCheck


var dead : bool = false # TODO implementirati smrt tako da upali ragdoll i posledice i pri pucnju/pogotku itemom
var dropped : bool = false
var thrown : bool = false
var drop_velocity: Vector3 = Vector3.ZERO
@export var ragdoll_time : float = 5
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var flying: bool = false
var target: Vector3
var flight_speed: float = 5.0
var run_off_height: float

@export var exibition: bool = false

func _ready() -> void:
	animation_player.play(starting_animation)
	if !exibition:
		set_dropped(Vector3.ZERO)


func _physics_process(delta: float) -> void:
	if dropped:
		if drop_velocity != Vector3.ZERO:
			velocity += drop_velocity
			drop_velocity = Vector3.ZERO
		velocity += get_gravity() / 2 * delta
		if is_on_floor():
			dropped = false
			if not dead:
				play_animation("Idle") # TODO nastaviti AI
	if thrown:
		ragdoll_time -= delta
		global_position = physical_bone.global_position
		return
	
	if flying:
		if run_off_height > 0.0:
			if run_off_height > global_position.y:
				target.y = lerp(target.y, run_off_height, delta)
			else:
				run_off_height = 0.0
		else:
			target.y = lerp(target.y, 0.0, delta / 2)
		var direction = global_position.direction_to(target)
		look_at(global_position + direction, Vector3.UP)
		if wall_check.is_colliding():
			avoid_wall()
		velocity = direction * flight_speed
		var pos_xz = Vector3(global_position.x, 0.0, global_position.z)
		var target_xz = Vector3(target.x, 0.0, target.z)
		if pos_xz.distance_to(target_xz) < 0.3:
			if is_on_floor():
				land()
			else:
				target = lerp(target, target + direction, 0.5)
	
	velocity.x = lerp(velocity.x, 0.0, delta)
	velocity.z = lerp(velocity.z, 0.0, delta)
	
	move_and_slide()


func avoid_wall() -> void:
	var collision_normal = wall_check.get_collision_normal()
	if collision_normal.y > 0.6: # zid gejming
		return
	var cur_dir = velocity.normalized()
	var new_dir = cur_dir.bounce(collision_normal).normalized()
	fly_to(global_position + new_dir * randf_range(3, 10), global_position.y + randf_range(0.5, 3))


func play_animation(animation : String):
	animation_player.play(animation)


func is_ragdolling() -> bool:
	return physical_bone_simulator_3d.is_simulating_physics()


func stop_ragdoll():
	physical_bone_simulator_3d.physical_bones_stop_simulation()
	thrown = false


func set_dropped(force: Vector3):
	global_rotation_degrees.x = 0
	global_rotation_degrees.z = 0
	drop_velocity += force
	dropped = true
	animation_player.play("Flying")


func set_thrown(force : Vector3):
	if not dead:
		animation_player.stop()
		dead = true
	physical_bone_simulator_3d.physical_bones_start_simulation()
	thrown = true
	for bone in physical_bone_simulator_3d.get_children():
		bone.apply_central_impulse(force * randf_range(1.0, 1.5))


func kill(force: Vector3) -> void:
	physical_bone_simulator_3d.physical_bones_stop_simulation()
	animation_player.stop()
	dead = true
	var eksplozija = galeb_eksplozija.instantiate()
	add_child(eksplozija)
	eksplozija.connect("finished", func() -> void:
		eksplozija.queue_free()
	)
	eksplozija.explode()
	physical_bone_simulator_3d.physical_bones_start_simulation()
	thrown = true
	for bone in physical_bone_simulator_3d.get_children():
		bone.apply_central_impulse(force * randf_range(1.0, 1.5))


func fly_to(target_loc: Vector3, height: float):
	run_off_height = height
	target = target_loc
	flying = true
	animation_player.play("Flying")


func land():
	global_rotation_degrees.x = 0
	global_rotation_degrees.z = 0
	flying = false
	velocity = Vector3.ZERO
	animation_player.play("Idle")


func get_inertia() -> Vector3:
	return physical_bone.linear_velocity


func _on_area_3d_area_entered(area: Area3D) -> void:
	if thrown:
		return
	
	var obj = area.get_parent_node_3d()
	var inertia: Vector3 = obj.get_inertia()
	if inertia.abs() > Vector3.ONE * 2: # magicni faking brojevi upomoc
		set_thrown(inertia / 7)


func _on_scare_area_body_entered(body: Node3D) -> void:
	if thrown or dropped or dead or exibition:
		return
	if body == self:
		return
	if body.is_in_group("Galeb") and !body.dead:
		return
	var direction = (global_position - body.global_position).normalized()
	direction.y = 0
	direction.x += randf_range(-1,1)
	var distance = randf_range(3, 10)
	var height = randf_range(0.1, 0.5) * distance
	fly_to(global_position + direction * distance, global_position.y + height)
