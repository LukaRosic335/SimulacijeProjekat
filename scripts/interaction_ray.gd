extends RayCast3D

@onready var camera_3d: Camera3D = $".."
@export var item_position := Vector3(0.5,-0.25,-0.5)
@onready var player: CharacterBody3D = $"../.."

@onready var item = null
@onready var target_serviceable = null

#signal drop_item(item : Node3D, item_position : Vector3)

func __find_target() -> Node:
	if !is_colliding():
		return null
	
	return get_collider().get_parent()


func interact() -> void:
	var target = __find_target()
	if !target:
		return
		
	if target.is_in_group("Pickable"):
		player.holster()
		pick_up(target)


func pick_up(target) -> void:
	if item != null:
		drop(Vector3.ZERO)
	item = target
	#item.apply_force(Vector3.ZERO, item.global_position)
	item.get_parent().remove_child(item)
	camera_3d.add_child(item)
	item.position = item_position
	# TODO namestiti rotaciju itema
	if item.is_in_group("Galeb"):
		if not item.dead:
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
	camera_3d.remove_child(item)
	player.drop_item.emit(item, global_position - camera_3d.basis.z, force)
	item = null
