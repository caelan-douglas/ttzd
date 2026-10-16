extends Camera3D

@export var target: Node3D
@export var follow_speed := 5.0
@export var zoom_speed := 1.5
@export var min_zoom := 7.0
@export var max_zoom := 30.0

# Camera rotation
@export var rotation_sensitivity := 0.005
@export var min_pitch := -80.0
@export var max_pitch := -15.0

var camera_offset := Vector3.ZERO
var zoom_distance := 0.0

var yaw := 0.0
var pitch := 0.0
var rotating := false


func _ready() -> void:
	if target == null:
		return

	camera_offset = global_position - target.global_position
	zoom_distance = camera_offset.length()

	# initial camera rotation from current position
	yaw = atan2(camera_offset.x, camera_offset.z)
	pitch = asin(clampf(-camera_offset.y / zoom_distance, -1.0, 1.0))


func _process(delta: float) -> void:
	if target == null:
		return

	# Calculate camera position from rotation
	var direction := Vector3(sin(yaw) * cos(pitch), -sin(pitch), cos(yaw) * cos(pitch))

	var desired_position := target.global_position + direction * zoom_distance
	var weight := 1.0 - exp(-follow_speed * delta)

	# lerp on camera turn
	global_position = global_position.lerp(desired_position, weight)

	if global_position.distance_squared_to(target.global_position) > 0.0001:
		look_at(target.global_position, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	# Right-click camera rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	# Rotate while holding right-click
	if event is InputEventMouseMotion and rotating:
		yaw -= event.relative.x * rotation_sensitivity
		pitch -= event.relative.y * rotation_sensitivity

		pitch = clampf(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

	# Mouse wheel zoom
	if event.is_action_pressed("zoom_in"):
		zoom_distance = clampf(zoom_distance - zoom_speed, min_zoom, max_zoom)

	elif event.is_action_pressed("zoom_out"):
		zoom_distance = clampf(zoom_distance + zoom_speed, min_zoom, max_zoom)
