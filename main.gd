extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$BuildArea/Grid.material.set_shader_parameter("pos", event.position);
