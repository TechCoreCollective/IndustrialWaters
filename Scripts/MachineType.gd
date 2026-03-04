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
	MachineData.MachineType.DrillLiquid : "oil_drill",
	MachineData.MachineType.Smelter : "smelter",
	MachineData.MachineType.Crafter : "crafter",
	MachineData.MachineType.Collector : "collector",
	MachineData.MachineType.ConveyorBelt : "conveyor"
}

signal storage_modified

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
var currently_crafting := false

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
	return result

func get_rect():
	var machine_size: Vector2 = Vector2.ZERO
	if machine_type in MachineData.machine_sizes:
		machine_size = MachineData.machine_sizes[machine_type]
	var upper_left_tile = place_position - Vector2i(machine_size / 2)
	var machine_rect = Rect2(upper_left_tile, machine_size)
	return machine_rect

enum ProcessingLevel {
	Generation,
	Intermediate,
	Terminator
}

func get_process_level() -> ProcessingLevel:
	if machine_type in MachineData.Generators: return ProcessingLevel.Generation
	if machine_type == MachineData.MachineType.Collector: return ProcessingLevel.Terminator
	return ProcessingLevel.Intermediate

func get_type(): return MachineData.MachineType.find_key(machine_type)

func repair():
	MachineData.is_in_minigame = false
	is_damaged = false
	has_been_repaired = true
	var grid = MachineData.get_parent().get_node("PlacementGrid")
	grid.display_scene()

func get_craft_cost():
	if not recipe in Machinejson.parsed_data: return null
	var machine_json = Machinejson.parsed_data[recipe]
	var crafting_costs = machine_json["craft_cost"]
	return crafting_costs

func contains_all_required_items(items):
	if items == null: return false
	for required_item in items:
		var item_type = GlobalInventory.convert_name_to_enum(required_item["id"])
		var item_amount = required_item["amount"]
		var count_in_internal_storage = 0
		if item_type in received_items: count_in_internal_storage = received_items[item_type]
		if item_amount > count_in_internal_storage: return false
	return true

func remove_all_required_items(items):
	if items == null: return false
	for required_item in items:
		var item_type = GlobalInventory.convert_name_to_enum(required_item["id"])
		var item_amount = required_item["amount"]
		var new_item_count = received_items[item_type] - item_amount
		if new_item_count < 0: new_item_count = 0
		received_items[item_type] = new_item_count
		if new_item_count == 0: received_items.erase(item_type)
	storage_modified.emit()
