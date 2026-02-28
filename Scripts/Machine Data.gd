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
	MachineType.DrillSolid: 1
}

var machine_sizes: Dictionary[MachineType, Vector2] = {
	MachineType.DrillSolid: Vector2(3, 3)
}

signal drag_start
signal drag_end
var dragged_type := MachineType.None
