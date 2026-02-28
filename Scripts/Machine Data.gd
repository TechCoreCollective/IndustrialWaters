extends Node

enum MachineType {
	DrillSolid,
	DrillLiquid,
	Smelter,
	Manufactor,
	Collector,
	ConveyorBelt,
	None
}

var obtainedMachines: Dictionary[MachineType, int] = {
	MachineType.DrillSolid: 6,
	MachineType.DrillLiquid: 3,
	MachineType.Smelter: 3
}

var machine_sizes: Dictionary[MachineType, Vector2] = {
	MachineType.DrillSolid: Vector2(3, 3),
	MachineType.DrillLiquid: Vector2(3, 3),
	MachineType.Smelter: Vector2(2, 2),
	MachineType.ConveyorBelt: Vector2.ONE
}

signal drag_start
signal drag_end
var dragged_type := MachineType.None
var previous_dragged := MachineType.None

var placed_machines: Array[Machine]

func get_texture_from_type(machine_type: MachineType):
	var resulting_texture = null
	match machine_type:
		MachineType.DrillSolid: resulting_texture = UID.IMG_SOLID_DRILL_GRID
		MachineType.DrillLiquid: resulting_texture = UID.IMG_OIL_DRILL_GRID
		MachineType.Smelter: resulting_texture = UID.IMG_SMELTER_GRID
	return resulting_texture

var hovered_button_machine_type := MachineType.None

func get_clicked_machine_info():
	var placement_grid = get_parent().get_node("PlacementGrid")
	var hovered_index = placement_grid.get_hovered()
	for machine: Machine in placed_machines:
		var machine_rect = machine.get_rect()
		if machine_rect.has_point(hovered_index): return machine
	return null
