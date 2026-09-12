extends RayCast3D


@onready var head: Node3D = $".."
@onready var player: Player = $"../../.."

@export var item_position := Vector3(-0.5,-0.5,-0.5)

@onready var item = null


func __find_target() -> Node:
	if !is_colliding():
		return null
	
	var target = get_collider().get_parent()
	
	if !__target_is_visible(target):
		return null
	
	return target


func interact() -> void:
	var target = __find_target()
	if !target:
		return
	
	if target.is_in_group("Pickable"):
		pick_up(target)


func pick_up(target) -> void:
	if item != null:
		drop(Vector3.ZERO)
	item = target
	#item.apply_force(Vector3.ZERO, item.global_position)
	item.reparent(head)
	item.position = item_position
	# TODO namestiti rotaciju itema
	if item.is_in_group("Galeb"):
		if not item.dead:
			item.velocity = Vector3.ZERO
			item.play_animation("Struggle")
		if item.is_ragdolling():
			item.stop_ragdoll()
	if item.is_in_group("Item"):
		item.freeze = true
	print("Item picked up") # DEBUG


func drop(force: Vector3):
	if item == null:
		print("No item") # DEBUG
		return
	player.drop_item.emit(item, force)
	item = null


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
