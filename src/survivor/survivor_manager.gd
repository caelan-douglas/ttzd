extends Node3D

@export var truck: CharacterBody3D
@export var camera: Camera3D
@export var survivor_scene: PackedScene
@export var recruitment_panel: Control
@export var recruit_button: Button
@export var survivor_count := 12
@export var spawn_radius := 80.0

var selected_survivor: Area3D


func _ready() -> void:
	if recruitment_panel == null or recruit_button == null:
		push_warning("Survivors: Assign Recruitment Panel and Recruit Button in the Inspector.")
		return

	recruitment_panel.hide()
	recruit_button.pressed.connect(_on_recruit_pressed)

	if truck == null or camera == null or survivor_scene == null:
		push_warning("Survivors: Assign Truck, Camera and Survivor Scene in the Inspector.")
		return

	spawn_survivors()


func spawn_survivors() -> void:
	if survivor_scene == null or truck == null:
		return

	for i in range(survivor_count):
		var survivor := survivor_scene.instantiate() as Area3D
		if survivor == null:
			continue

		add_child(survivor)

		var angle := randf_range(0.0, TAU)
		var distance := randf_range(12.0, spawn_radius)

		var offset := Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)

		survivor.global_position = Vector3(truck.global_position.x + offset.x, truck.global_position.y, truck.global_position.z + offset.z)

		survivor.set("truck", truck)


func _process(_delta: float) -> void:
	if selected_survivor == null:
		return

	if not is_instance_valid(selected_survivor):
		selected_survivor = null
		recruitment_panel.hide()
		return

	if not selected_survivor.call("can_recruit"):
		selected_survivor = null
		recruitment_panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_survivor(event.position)


func select_survivor(mouse_position: Vector2) -> void:
	if camera == null or recruitment_panel == null:
		return

	var origin := camera.project_ray_origin(mouse_position)
	var end := origin + camera.project_ray_normal(mouse_position) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	selected_survivor = null
	recruitment_panel.hide()

	if result.is_empty():
		return

	var survivor := result["collider"] as Area3D

	if survivor == null:
		return

	if survivor.has_method("can_recruit") and survivor.call("can_recruit"):
		selected_survivor = survivor
		recruitment_panel.show()


func _on_recruit_pressed() -> void:
	if not is_instance_valid(selected_survivor):
		return

	if not selected_survivor.call("can_recruit"):
		return

	if truck != null and truck.has_method("add_trailer"):
		truck.call("add_trailer")

	selected_survivor.queue_free()
	selected_survivor = null
	recruitment_panel.hide()
