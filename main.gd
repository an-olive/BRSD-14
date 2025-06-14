extends Control

func _ready() -> void:
	for btn in $SidePanel/Inventory.get_children():
		if btn is Button:
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

func _on_game_buildings_change() -> void:
	for building in $SidePanel/Inventory/Buildings.get_children():
		$SidePanel/Inventory/Buildings.remove_child(building)

	for building in $Game.stats.buildings:
		if not building.on_selected.is_connected(on_building_select):
			building.on_selected.connect(on_building_select)
		if not building.on_place.is_connected(on_building_place):
			building.on_place.connect(on_building_place)
		$SidePanel/Inventory/Buildings.add_child(building)

func on_building_select(building: InventoryBuilding) -> void:
	for b in $Game.stats.buildings:
		if b != building:
			b.selected = false

func on_building_place(building: InventoryBuilding) -> void:
	if not building.building.is_valid_position(building.location):
		return
	$Game.place_building(building)
