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

var Generators = [MachineType.DrillSolid, MachineType.DrillLiquid]

var obtainedMachines: Dictionary[MachineType, int] = {
	MachineType.DrillSolid: 6,
	MachineType.DrillLiquid: 3,
	MachineType.Smelter: 3
}

var machine_sizes: Dictionary[MachineType, Vector2] = {
	MachineType.DrillSolid: Vector2(3, 3),
	MachineType.DrillLiquid: Vector2(3, 3),
	MachineType.Smelter: Vector2(4, 4),
	MachineType.ConveyorBelt: Vector2.ONE
}

var corner_exception: Array[MachineType] = [MachineType.Smelter]
var machine_y_invalid: Dictionary[MachineType, int] = {
	MachineType.Smelter: 2
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

var active_conwayerors: Dictionary[int, Array]
var conway_path_points: Dictionary[int, Array]
var traveling_conway_items: Array[ConwayItem]
var highest_conwayor_index: int = -1

func resources_produced(machine: Machine, item_produced: GlobalInventory.ItemType):
	var travelling_item = ConwayItem.ctor(item_produced)
	travelling_item.conway_path_index = get_path_index_of_produced_item(machine)
	if travelling_item.conway_path_index == -1: return
	traveling_conway_items.append(travelling_item)

func get_machine_by_pos(position: Vector2i):
	for machine: Machine in placed_machines:
		if machine.place_position == position: return machine

func get_path_index_of_produced_item(producer: Machine):
	var conways_in_machine: Array = []
	for machine: Machine in placed_machines:
		if machine.machine_type != MachineType.ConveyorBelt: continue
		if not producer.get_rect().has_point(machine.place_position): continue
		conways_in_machine.append(machine.place_position)
	if conways_in_machine.size() == 0: return -1
	var item_spawn_index = randi_range(0, conways_in_machine.size()-1)
	var item_spawn_position = conways_in_machine[item_spawn_index]
	for path_index in conway_path_points.keys():
		var path = conway_path_points.values()[path_index]
		if item_spawn_position in path: return path_index
	return -1
