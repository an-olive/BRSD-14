extends Control

const Building = preload("res://Components/building.gd")

func _ready() -> void:
	Building.init_weights()
	
	for btn in $SidePanel/Inventory.get_children():
		if btn is Button:
			btn.connect("button_down", func(): btn.get_child(0).position += Vector2(1, 1))
			btn.connect("button_up", func(): btn.get_child(0).position -= Vector2(1, 1))
			
	_on_game_costs_change()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$BuildArea/Grid.material.set_shader_parameter("pos", event.position)

	if event.is_action_pressed("pause"):
		Game.instance.paused = !Game.instance.paused
		$PauseOverlay.visible = Game.instance.paused

func _process(delta: float) -> void:
	$SidePanel/Stats/Gibs/Value.text = Game.int_to_string($Game.stats.gibs)
	$SidePanel/Stats/Force/Value.text = Game.int_to_string($Game.stats.force)
	$SidePanel/Stats/Rotation/Value.text = Game.int_to_string($Game.stats.rotation)
	$SidePanel/Stats/Expansion/Value.text = Game.int_to_string($Game.stats.expansion)
	
	$SidePanel/Inventory/GibsButton.disabled = $Game.gib_costs.is_empty() \
			or $Game.gib_costs.front() > $Game.stats.gibs
	$SidePanel/Inventory/ForceButton.disabled = $Game.force_milestones.is_empty() \
			or $Game.force_milestones.front() > $Game.stats.max_force
	$SidePanel/Inventory/RotationButton.disabled = $Game.rotation_milestones.is_empty() \
			or $Game.rotation_milestones.front() > $Game.stats.max_rotation
	$SidePanel/Inventory/ExpansionButton.disabled = $Game.expansion_milestones.is_empty() \
			or $Game.expansion_milestones.front() > $Game.stats.max_expansion

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

func _on_game_costs_change() -> void:
	$SidePanel/Inventory/GibsButton.text = Game.int_to_string($Game.gib_costs.front())
	$SidePanel/Inventory/ForceButton.text = Game.int_to_string($Game.force_milestones.front())
	$SidePanel/Inventory/RotationButton.text = Game.int_to_string($Game.rotation_milestones.front())
	$SidePanel/Inventory/ExpansionButton.text = Game.int_to_string($Game.expansion_milestones.front())

func _on_game_building_purchase() -> void:
	var building = Building.buildings["Producer"].instantiate().as_inventory()
	$Game.stats.buildings.append(building)
	_on_game_buildings_change()
