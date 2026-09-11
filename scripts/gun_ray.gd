extends RayCast3D

@onready var head: Node3D = $"../.."


func get_target() -> Node:
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
