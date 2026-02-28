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

var machine_type: MachineData.MachineType
var place_position: Vector2i
var conveyor_face_dir: ConveyorFaceDir

static func ctor(type: MachineData.MachineType, pos: Vector2) -> Machine:
	var result: Machine = Machine.new()
	result.machine_type = type
	result.place_position = pos
	return result

func get_rect():
	var machine_size: Vector2 = MachineData.machine_sizes[machine_type]
	var upper_left_tile = place_position - Vector2i(machine_size / 2)
	var machine_rect = Rect2(upper_left_tile, machine_size)
	return machine_rect
