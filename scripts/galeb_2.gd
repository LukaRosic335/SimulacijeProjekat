extends CharacterBody3D

@export_enum("T_Pose", "Idle", "Peck_Floor", "Peck_Wall", "Flying", "Walking", "Struggle") var starting_animation : String = "T_Pose"

@onready var animation_player: AnimationPlayer = $galeb2/AnimationPlayer
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var physical_bone: PhysicalBone3D = $"galeb2/Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Telo"

var dead : bool = false # TODO implementirati smrt tako da upali ragdoll i posledice i pri pucnju/pogotku itemom
var dropped : bool = false
var thrown : bool = false
@export var ragdoll_time : float = 5
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	animation_player.play(starting_animation)

func _physics_process(delta: float) -> void:
	if dropped:
		velocity += get_gravity() * delta
		if is_on_floor():
			dropped = false
			if not dead:
				play_animation("Idle") # TODO nastaviti AI
	if thrown:
		ragdoll_time -= delta
		position = physical_bone.global_position
	move_and_slide()

func play_animation(animation : String):
	animation_player.play(animation)

func is_ragdolling() -> bool:
	return physical_bone_simulator_3d.is_simulating_physics()

func stop_ragdoll():
	physical_bone_simulator_3d.physical_bones_stop_simulation()
	thrown = false

func set_dropped():
	dropped = true

func set_thrown(force : Vector3):
	if not dead:
		animation_player.stop()
		dead = true
	physical_bone_simulator_3d.physical_bones_start_simulation()
	thrown = true
	physical_bone.apply_central_impulse(force * 2)
