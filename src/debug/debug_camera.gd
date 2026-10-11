extends Camera3D

const SPEED = 1200
const DAMP = 0.98

var vel : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fwd := Input.get_axis("back", "forward")
	var hor := Input.get_axis("left", "right")
	
	vel = lerp(vel, Vector2(hor * SPEED * delta, -fwd * SPEED * delta), 2 * delta)
	vel *= DAMP
	
	global_position.z += vel.y
	global_position.x += vel.x
