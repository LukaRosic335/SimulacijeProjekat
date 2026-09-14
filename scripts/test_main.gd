extends Node3D


func _process(delta: float) -> void:
	pass


func _on_player_drop_item(item: Node3D, force: Vector3) -> void:
	item.reparent(self)
	if item.is_in_group("Galeb"):
		if force.length() <= 1:
			if not item.dead:
				item.set_dropped(force)
			else:
				item.set_thrown(force)
				print("GALEB DROP")
		else:
			item.set_thrown(force)
			print("GALEB THROW")
	if item.is_in_group("Item"):
		item.freeze = false
		item.apply_impulse(force, item.global_position)
		item.apply_force(force / 4, item.global_position)
	print("Item dropped") # DEBUG


func _on_test_level_spawn_galeb(galeb: Galeb) -> void:
	galeb.reparent.call_deferred(self, true)
