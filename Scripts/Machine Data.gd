extends Node

enum MachineType {
	DrillSolid,
	DrillLiquid,
	Smelter,
	Crafter,
	Collector,
	ConveyorBelt,
	None
}

const Generators = [MachineType.DrillSolid, MachineType.DrillLiquid]
const Crafters = [MachineType.Smelter]

var obtainedMachines: Dictionary[MachineType, int] = {}

var machine_sizes: Dictionary[MachineType, Vector2] = {
	MachineType.DrillSolid: Vector2(3, 3),
	MachineType.DrillLiquid: Vector2(3, 3),
	MachineType.Smelter: Vector2(4, 4),
	MachineType.Collector: Vector2(3, 3),
	MachineType.Crafter: Vector2(3, 3),
	MachineType.ConveyorBelt: Vector2.ONE
}

var corner_exception: Array[MachineType] = [MachineType.Smelter]
var machine_y_invalid: Dictionary[MachineType, int] = {
	MachineType.Smelter: 2
}

var names = {
	"solid_drill": MachineType.DrillSolid,
	"oil_drill": MachineType.DrillLiquid,
	"smelter": MachineType.Smelter,
	"crafter": MachineType.Crafter,
	"collector": MachineType.Collector,
	"conveyor": MachineType.ConveyorBelt
}

signal drag_start
signal drag_end
var dragged_type := MachineType.None
var previous_dragged := MachineType.None

var placed_machines: Array[Machine] = [Machine.ctor(MachineType.DrillSolid, Vector2.ONE), Machine.ctor(MachineType.Crafter, Vector2(5, 4))]

func get_texture_from_type(machine_type: MachineType):
	var resulting_texture = null
	match machine_type:
		MachineType.DrillSolid: resulting_texture = UID.IMG_SOLID_DRILL_GRID
		MachineType.DrillLiquid: resulting_texture = UID.IMG_OIL_DRILL_GRID
		MachineType.Smelter: resulting_texture = UID.IMG_SMELTER_GRID
		MachineType.Collector: resulting_texture = UID.IMG_COLLECTOR_GRID
		MachineType.Crafter: resulting_texture = UID.IMG_CRAFTER_GRID
	return resulting_texture

var hovered_button_machine_type := MachineType.None
var is_in_minigame := false

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

func resources_produced(machine: Machine, item_produced: GlobalInventory.ItemType, path_exception := -1):
	if machine.is_damaged: return
	if item_produced == GlobalInventory.ItemType.None or item_produced == -1: return
	var travelling_item = ConwayItem.ctor(item_produced)
	var send_to_path_index = get_path_index_of_produced_item(machine, path_exception)
	travelling_item.conway_path_index = send_to_path_index
	if travelling_item.conway_path_index == -1: return
	travelling_item.creation_machine = machine
	traveling_conway_items.append(travelling_item)

func get_machine_by_pos(position: Vector2i):
	for machine: Machine in placed_machines:
		if machine.place_position == position: return machine

func get_path_index_of_produced_item(producer: Machine, path_exception: int):
	var path_indices_of_linked_conways: Array = []
	for machine: Machine in placed_machines:
		if machine.machine_type != MachineType.ConveyorBelt: continue
		if not producer.get_rect().has_point(machine.place_position): continue
		var conway_position = machine.place_position
		var conway_data = get_conwayer_at_pos(conway_position)
		path_indices_of_linked_conways.append(conway_data.conway_path_index)
		
	if path_indices_of_linked_conways.size() == 0: return -1
	if path_exception != -1 and path_indices_of_linked_conways.size() == 1: return -1
	
	var machine_conway_limit = path_indices_of_linked_conways.size() - 1
	var item_spawn_index = path_exception
	while item_spawn_index == path_exception:
		item_spawn_index = path_indices_of_linked_conways[randi_range(0, machine_conway_limit)]
	
	return item_spawn_index

var drag_ended_prematurely := false

func is_ui_open():
	var grid = get_parent().get_node("PlacementGrid")
	var machine_status = grid.get_node("MachineStatus")
	var inventory = grid.get_node("Panel2")
	return machine_status.visible or inventory.visible or is_in_minigame or grid.title_screen_on

func smelt_item(smelter: Machine, source_path: int):
	if smelter.recipe == "" or smelter.recipe == null: return
	var smelt_result = GlobalInventory.convert_name_to_enum(smelter.recipe)
	if smelt_result == GlobalInventory.ItemType.None: return
	resources_produced(smelter, smelt_result, source_path)

const minimum_time_for_damage = 15
const maximum_time_for_damage = 30

const enable_repairs = false
const machines_which_can_break = [MachineType.DrillSolid, MachineType.DrillLiquid, MachineType.Smelter]

func manage_machine_damage_timer(machine: Machine):
	if not enable_repairs: return
	if not machine.machine_type in machines_which_can_break: return
	var wait_time = randf_range(minimum_time_for_damage, maximum_time_for_damage) * machine.level
	if machine.has_been_repaired: return
	await get_tree().create_timer(wait_time).timeout
	var grid = get_parent().get_node("PlacementGrid")
	var machine_manager = grid.get_node("MachineManager")
	var machine_status = grid.get_node("MachineStatus")
	machine.is_damaged = true
	grid.display_scene()
	var hovered_machine = get_clicked_machine_info()
	if machine_status.visible and hovered_machine == machine_manager.latest_machine:
		machine_manager.display_machine_status()
	
func get_non_conwayer_at_pos(machine_pos: Vector2i) -> Machine: return get_machine_with_restrict_from_pos(machine_pos, true)
func get_conwayer_at_pos(machine_pos: Vector2i) -> Machine: return get_machine_with_restrict_from_pos(machine_pos, false)

func get_machine_with_restrict_from_pos(machine_pos: Vector2i, only_non_conways: bool) -> Machine:
	for machine: Machine in placed_machines:
		var is_conway = machine.machine_type == MachineType.ConveyorBelt
		if is_conway and only_non_conways or not is_conway and not only_non_conways: continue
		var machine_rect = machine.get_rect()
		if machine_rect.has_point(machine_pos): return machine
	return Machine.ctor(MachineData.MachineType.None, machine_pos)

func add_machine_to_inventory(machine_type: MachineType, amount: int = 1):
	if not machine_type in obtainedMachines: obtainedMachines[machine_type] = 0
	obtainedMachines[machine_type] += amount

func craft_item(machine: Machine):
	var craft_cost = machine.get_craft_cost()
	while machine.contains_all_required_items(craft_cost):
		machine.remove_all_required_items(craft_cost)
		var wanted_machine_type = names[machine.recipe]
		add_machine_to_inventory(wanted_machine_type)
	var machine_ui = get_parent().get_node("PlacementGrid").machine_ui_root
	machine_ui.update_ui()
