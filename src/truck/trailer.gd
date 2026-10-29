extends Node3D

@export var follow_speed := 20.0
@export var follow_distance := 4.0
@export var rotation_speed := 3.0

var follow_target: Node3D


func _physics_process(delta: float) -> void:
	if follow_target == null:
		return

	var desired_position := follow_target.global_position + follow_target.global_transform.basis.z * follow_distance
	var weight := 1.0 - exp(-follow_speed * delta)
	var rotation_weight := 1.0 - exp(-rotation_speed * delta)

	global_position = global_position.lerp(desired_position, weight)
	rotation.y = lerp_angle(rotation.y, follow_target.rotation.y, rotation_weight)
