class_name Zombro
extends Character

@onready var agent : NavigationAgent3D = $NavigationAgent3D

func _get_movement_direction () -> Vector3:
	print((agent.get_next_path_position() - global_position).normalized())
	return (agent.get_next_path_position() - global_position).normalized()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	agent.target_position = Context.player.global_position
	pass
