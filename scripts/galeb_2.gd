class_name Galeb
extends CharacterBody3D

@export_enum("T_Pose", "Idle", "Peck_Floor", "Peck_Wall", "Flying", "Walking", "Struggle") var starting_animation : String = "T_Pose"
enum ai_state {walking, flying, peck_floor, idle, dropped, thrown, NULL, held}
@onready var ai_states:  = [ai_state.walking, ai_state.flying, ai_state.peck_floor, ai_state.idle]

@onready var animation_player: AnimationPlayer = $galeb2/AnimationPlayer
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var physical_bone: PhysicalBone3D = $"galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Telo"
@onready var galeb_eksplozija = preload("res://scenes/galeb_eksplozija.tscn")
@onready var scare_area: Area3D = $ScareArea
@onready var wall_check: RayCast3D = $WallCheck


var state : ai_state = ai_state.NULL
var dead : bool = false
var drop_velocity: Vector3 = Vector3.ZERO
@export var ragdoll_time : float = 5
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var target: Vector3
var flight_speed: float = 5.0
var run_off_height: float
var walk_speed: float = 1.0

var timer: float

@export var exibition: bool = false

func _ready() -> void:
	animation_player.play(starting_animation)
	if !exibition:
		set_dropped(Vector3.ZERO)


func _physics_process(delta: float) -> void:
	match state:
		ai_state.NULL:
			if is_on_floor() and !exibition:
				start_ai()
		ai_state.held:
			return
		ai_state.dropped:
			if drop_velocity != Vector3.ZERO:
				velocity += drop_velocity
				drop_velocity = Vector3.ZERO
			velocity += get_gravity() / 2 * delta
			if is_on_floor():
				if not dead:
					start_ai()
		ai_state.thrown:
			ragdoll_time -= delta
			global_position = physical_bone.global_position
			return
		ai_state.walking:
			var direction = global_position.direction_to(target)
			look_at(global_position + direction, Vector3.UP)
			if wall_check.is_colliding():
				avoid_wall()
			direction.y = 0
			velocity = direction * walk_speed
			velocity.y -= 9.81 * delta
			var pos_xz = Vector3(global_position.x, 0.0, global_position.z)
			var target_xz = Vector3(target.x, 0.0, target.z)
			if pos_xz.distance_to(target_xz) < 0.3:
				if is_on_floor():
					land()
				else:
					target = lerp(target, target + direction, 0.5)
		ai_state.flying:
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
		ai_state.peck_floor:
			timer -= delta
			if timer <= 0:
				start_ai()
		ai_state.idle:
			timer -= delta
			if timer <= 0:
				start_ai()
	
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

func set_held():
	scare_area.monitoring = false
	global_rotation_degrees.x = 0
	global_rotation_degrees.z = 0
	velocity = Vector3.ZERO
	state = ai_state.held
	if !dead:
		animation_player.play("Struggle")


func is_ragdolling() -> bool:
	return physical_bone_simulator_3d.is_simulating_physics()


func stop_ragdoll():
	physical_bone_simulator_3d.physical_bones_stop_simulation()


func set_dropped(force: Vector3):
	global_rotation_degrees.x = 0
	global_rotation_degrees.z = 0
	drop_velocity += force
	state = ai_state.dropped
	animation_player.play("Flying")


func set_thrown(force : Vector3):
	if not dead:
		animation_player.stop()
		dead = true
	physical_bone_simulator_3d.physical_bones_start_simulation()
	state = ai_state.thrown
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
	state = ai_state.thrown
	for bone in physical_bone_simulator_3d.get_children():
		bone.apply_central_impulse(velocity.normalized() + force * randf_range(1.0, 1.5))


func fly_to(target_loc: Vector3, height: float):
	run_off_height = height
	target = target_loc
	state = ai_state.flying
	animation_player.play("Flying")


func land():
	global_rotation_degrees.x = 0
	global_rotation_degrees.z = 0
	velocity = Vector3.ZERO
	start_ai()


func get_inertia() -> Vector3:
	return physical_bone.linear_velocity


func _on_area_3d_area_entered(area: Area3D) -> void:
	if state == ai_state.thrown:
		return
	
	var obj = area.get_parent_node_3d()
	var inertia: Vector3 = obj.get_inertia()
	if inertia.abs() > Vector3.ONE * 2: # magicni faking brojevi upomoc
		set_thrown(inertia / 7)


func _on_scare_area_body_entered(body: Node3D) -> void:
	if exibition or dead or state == ai_state.thrown or state == ai_state.dropped:
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


func walk_to(pos: Vector3) -> void:
	var projection = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pos, pos + Vector3.DOWN * 30.0)
	var result = projection.intersect_ray(query)
	if result:
		target = result.position
	else:
		start_ai()
	state = ai_state.walking
	animation_player.play("Walking")


func start_ai() -> void:
	# odaberi random akciju
	var new_state: ai_state = ai_states[randi_range(0, ai_states.size() - 1)]
	match new_state:
		ai_state.walking:
			var angle = randf_range(0.0, TAU)
			var distance= randf_range(2,15)
			var offset = Vector3(cos(angle), 0.0, sin(angle)) * distance
			var target_pos = global_position + offset
			walk_to(target_pos)
		ai_state.flying:
			var angle = randf_range(0.0, TAU)
			var distance = randf_range(2,15)
			var offset = Vector3(cos(angle), 0.0, sin(angle)) * distance
			var height = randf_range(0.1, 0.5) * distance
			fly_to(global_position + offset * distance, global_position.y + height)
		ai_state.peck_floor:
			animation_player.play("Peck_Floor")
			timer = randi_range(3, 10)
			state = ai_state.peck_floor
		ai_state.idle:
			animation_player.play("Idle")
			timer = randf_range(3, 10)
			state = ai_state.idle
