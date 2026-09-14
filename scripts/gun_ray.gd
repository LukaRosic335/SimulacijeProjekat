class_name ShotgunRaycast
extends RayCast3D

@onready var head: Node3D = $"../.."


func get_target() -> Node:
	var forward = -head.global_transform.basis.z
	var right = head.global_transform.basis.x
	var up = head.global_transform.basis.y
	
	var spread = tan(deg_to_rad(8))
	var angle = randf_range(0.0, TAU)
	var radius = sqrt(randf()) * spread
	
	var direction = (forward + right * cos(angle) * radius + up * sin(angle) * radius).normalized()
	target_position = to_local(global_position + direction * 100)
	force_raycast_update()
	
	if !is_colliding():
		return null
	var target = get_collider().get_parent()
	if !__target_is_visible(target):
		return null
	return target

func __target_is_visible(target: Node3D) -> bool:
	var from := head.global_position
	var to := target.global_position
	
	var query := PhysicsRayQueryParameters3D.create(
		from,
		to,
		1 << 1 # bit mask za teren vradzbina
	)
	
	query.collide_with_bodies = true
	query.collide_with_areas = false
	
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	
	return result.is_empty()
