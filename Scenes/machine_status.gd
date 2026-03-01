extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")
@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var button: Button = $VBoxContainer/Button
@onready var name_label: Label = $VBoxContainer/Name
@onready var option_button: OptionButton = $VBoxContainer/OptionButton
@onready var item_list2: VBoxContainer = $VBoxContainer/ScrollContainer2/ItemList
@onready var repair_button = $VBoxContainer/Repair

const COSTS = "upgrade_costs"
const INFO = "info"

var machine : Machine;
var max_level : int;

func _ready():
	source.resized.connect(_sync_size)
	button.pressed.connect(_upgrade)
	option_button.item_selected.connect(_set_recipe)
	
func set_machine(machine):
	if machine == null:
		return
	self.machine = machine
	_update_res()

func _update_res():
	if machine == null:
		return

	var machine_json = Machinejson.parsed_data.get(machine.name)
	if machine_json == null:
		return

	max_level = machine_json.get("max_level", 0)
	repair_button.visible = machine.is_damaged
	var options = ["No Recipe"]

	var recipes = machine_json.get("recipes", [])
	if recipes:
		options.append_array(recipes)

	option_button.clear()

	for i in options:
		option_button.add_item(i)

	if machine.recipe != "":
		option_button.select(options.find(machine.recipe))

	var base = machine.name.capitalize() + " Lv. " + str(machine.level)
	if machine.level == max_level:
		base += " (MAX)"
		button.visible = false
	else:
		button.visible = true

	name_label.text = base

	var row_scene = load("res://Inventory/ItemRow.tscn")

	for i in item_list.get_children():
		i.queue_free()

	for i in item_list2.get_children():
		i.queue_free()

	var upgrade_costs = machine_json.get(COSTS, {})
	var level_costs = upgrade_costs.get(str(machine.level), [])
	for item in level_costs:
		var row = row_scene.instantiate()
		var inventory_item = inventory.get_item_from_id(item.get("id"))
		if inventory_item == null:
			continue
		row.setup(inventory_item.name, inventory_item.icon, item.get("amount"))
		item_list.add_child(row)
		
	var received_items_snapshot = machine.received_items.duplicate()
	for item in received_items_snapshot.keys():
		var row = row_scene.instantiate()

		var item_name = GlobalInventory.convert_enum_to_name(item)
		var inventory_item = inventory.get_item_from_id(item_name)
		if inventory_item == null:
			continue

		row.setup(inventory_item.name, inventory_item.icon, received_items_snapshot.get(item))
		item_list2.add_child(row)
		
			
	_sync_size()

func _upgrade():
	var machine_json = Machinejson.parsed_data.get(machine.name)
	if machine_json == null:
		return

	var upgrade_costs = machine_json.get(COSTS, {})
	var level_costs = upgrade_costs.get(str(machine.level), [])
	var can_craft = Utils.remove_resources_safe(level_costs)
	if not can_craft:
		return

	machine.level += 1
	machine.multiplier = 2 ** (machine.level-1)

	_update_res()

func _sync_size():
	target.size = source.size
	target.position = source.position
	
func _set_recipe(index: int):
	var text = option_button.get_item_text(index)
	if text != "No Recipe":
		machine.recipe = text
	else:
		text = ""

func _on_repair_pressed():
	MachineData.is_in_minigame = true
	var welding_child = UID.SCN_WELDING.instantiate()
	welding_child.to_be_repaired_machine = machine
	get_parent().add_child(welding_child)
