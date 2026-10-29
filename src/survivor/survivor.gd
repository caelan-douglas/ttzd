extends Area3D

@export var recruitment_radius := 6.0

var truck: Node3D


func can_recruit() -> bool:
	if truck == null:
		return false

	var survivor_position := Vector2(global_position.x, global_position.z)
	var truck_position := Vector2(truck.global_position.x, truck.global_position.z)

	return survivor_position.distance_to(truck_position) <= recruitment_radius
