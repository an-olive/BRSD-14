extends Control

func _ready() -> void:
	for btn in $SidePanel/Inventory.get_children():
		btn.connect("button_down", func(): btn.get_child(0).position += Vector2(1, 1))
		btn.connect("button_up", func(): btn.get_child(0).position -= Vector2(1, 1))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$BuildArea/Grid.material.set_shader_parameter("pos", event.position)
		
	if event.is_action_pressed("pause"):
		Game.instance.paused = !Game.instance.paused
		$PauseOverlay.visible = Game.instance.paused

func _process(delta: float) -> void:
	$SidePanel/Stats/Gibs/Value.text = "%d" % $Game.stats.gibs
	$SidePanel/Stats/Force/Value.text = "%d" % $Game.stats.force
	$SidePanel/Stats/Rotation/Value.text = "%d" % $Game.stats.rotation
	$SidePanel/Stats/Expansion/Value.text = "%d" % $Game.stats.expansion
