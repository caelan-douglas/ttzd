extends Camera3D

@export var target: Node3D
@export var follow_speed := 5.0
@export var zoom_speed := 1.5
@export var min_zoom := 7.0
@export var max_zoom := 30.0

# Isometric camera settings
@export var camera_angle := 45.0
@export var camera_rotation := 45.0

var zoom_distance := 20.0


func _ready() -> void:
	if target == null:
		return

	# initial camera position
	_update_camera_position()
	look_at(target.global_position, Vector3.UP)


func _process(delta: float) -> void:
	if target == null:
		return

	# Calculate camera position
	var direction := Vector3(
		sin(deg_to_rad(camera_rotation)) * cos(deg_to_rad(camera_angle)), sin(deg_to_rad(camera_angle)), cos(deg_to_rad(camera_rotation)) * cos(deg_to_rad(camera_angle)))

	var desired_position := target.global_position + direction * zoom_distance
	var weight := 1.0 - exp(-follow_speed * delta)

	# lerp on camera turn
	global_position = global_position.lerp(desired_position, weight)

	look_at(target.global_position, Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Zoom in
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			size = clampf(size - zoom_speed, min_zoom, max_zoom)

		# Zoom out
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			size = clampf(size + zoom_speed, min_zoom, max_zoom)


func _update_camera_position() -> void:
	var direction := Vector3(sin(deg_to_rad(camera_rotation)) * cos(deg_to_rad(camera_angle)),sin(deg_to_rad(camera_angle)),cos(deg_to_rad(camera_rotation)) * cos(deg_to_rad(camera_angle)))

	global_position = target.global_position + direction * zoom_distance
