extends Node

enum MachineType {
	DrillSolid,
	DrillLiquid,
	Smelter,
	Manufactor,
	Collector,
	ConveyorBelt
}


var obtainedMachines: Dictionary[MachineType, int] = {
	MachineType.DrillSolid: 1,
	MachineType.DrillLiquid: 1,
	MachineType.Manufactor: 1
}
