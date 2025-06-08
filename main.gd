extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$BuildArea/Grid.material.set_shader_parameter("pos", event.position)
		
	if event.is_action_pressed("pause"):
		Game.instance.paused = !Game.instance.paused
		$PauseOverlay.visible = Game.instance.paused
