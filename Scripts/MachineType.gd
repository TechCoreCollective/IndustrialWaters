class_name Machine
extends Resource

enum ConveyorFaceDir {
	Unknown = -1,
	Vertical,
	Horizontal,
	UpRight,
	UpLeft,
	DownRight,
	DownLeft
}

var names = {
	MachineData.MachineType.DrillSolid : "solid_drill",
	MachineData.MachineType.DrillLiquid : "liquid_drill",
	MachineData.MachineType.Smelter : "smelter",
	MachineData.MachineType.Manufactor : "manufactor",
	MachineData.MachineType.Collector : "collector",
	MachineData.MachineType.ConveyorBelt : "conveyor"
}

var data: Dictionary = {}
var machine_type: MachineData.MachineType
var place_position: Vector2i
var conveyor_face_dir: ConveyorFaceDir
var received_items: Dictionary[int, int]
var recipe : String
var multiplier : int
var name : String
var level : int
var conway_path_index: int
var is_damaged := false
var has_been_repaired := false

static func ctor(type: MachineData.MachineType, pos: Vector2) -> Machine:
	var result: Machine = Machine.new()
	result.machine_type = type
	result.place_position = pos
	result.data = {}
	result.received_items = {}
	if not type in result.names.keys(): result.name = ""
	else: result.name = result.names.get(type)
	result.recipe = ""
	result.level = 1
	result.multiplier = 1
	if type != MachineData.MachineType.ConveyorBelt:
		MachineData.manage_machine_damage_timer(result)
	return result

func get_rect():
	var machine_size: Vector2 = Vector2.ZERO
	if machine_type in MachineData.machine_sizes:
		machine_size = MachineData.machine_sizes[machine_type]
	var upper_left_tile = place_position - Vector2i(machine_size / 2)
	var machine_rect = Rect2(upper_left_tile, machine_size)
	return machine_rect
