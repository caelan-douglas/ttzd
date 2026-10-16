extends CharacterBody3D

@export var acceleration := 12.0
@export var max_speed := 18.0
@export var reverse_speed := 7.0
@export var friction := 6.0
@export var brake_strength := 20.0
@export var steering_speed := 1.5

var current_speed := 0.0


func _physics_process(delta: float) -> void:
	var throttle := Input.get_axis("reverse", "accelerate")
	var steering := Input.get_axis("steer_right", "steer_left")

	# Acceleration/reversing
	if Input.is_action_pressed("brake"):
		current_speed = move_toward(current_speed, 0.0, brake_strength * delta)
	elif throttle != 0.0:
		var target_speed := max_speed if throttle > 0.0 else -reverse_speed
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * delta)

	# Steering
	if abs(current_speed) > 0.1:
		var speed_factor := clampf(abs(current_speed) / max_speed, 0.0, 1.0)
		var reverse_factor := -1.0 if current_speed < 0.0 else 1.0

		rotation.y += steering * steering_speed * speed_factor * reverse_factor * delta

	# Forward
	var forward := -global_transform.basis.z
	velocity = forward * current_speed

	move_and_slide()
