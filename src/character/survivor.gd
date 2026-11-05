class_name Survivor
extends Character

@export var recruitment_radius := 6.0

func can_recruit() -> bool:
	if Context.player == null:
		print("fart")
		return false

	var survivor_position := Vector2(global_position.x, global_position.z)
	var truck_position := Vector2(Context.player.global_position.x, Context.player.global_position.z)

	return survivor_position.distance_to(truck_position) <= recruitment_radius
