extends RayCast3D


func get_target() -> Node:
	if !is_colliding():
		return null
	return get_collider().get_parent()
