extends Control

const Building = preload("res://Components/building.gd")

func _ready() -> void:
	Building.init_weights()
	for i in range(5):
		$Buildings.add_child(roll_building())

func roll_building() -> InventoryBuilding:
	var weight_sum = 0
	for value in Building.weights.values():
		weight_sum += value
	var r = randf_range(0, weight_sum)
	for name in Building.buildings.keys():
		r -= Building.weights[name]
		if r <= 0:
			return Building.buildings[name].instantiate().as_inventory()
	return Building.buildings.values().back().instantiate().as_inventory()
