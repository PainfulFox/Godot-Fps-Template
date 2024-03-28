class_name NyaPhysics
extends Node3D

static func Raycast(start, direction, distance, collision_exclusion):
	var space_state = start.get_world_3d().direct_space_state
	var origin = start.global_position
	var end = start.global_position + direction * distance

	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.exclude = collision_exclusion
	query.collide_with_areas = false

	var result = space_state.intersect_ray(query)

	if result:
		return result
	else: 
		return
