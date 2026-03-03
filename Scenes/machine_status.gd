extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer
@onready var upgrade_cost_list: VBoxContainer = $"VBoxContainer/Upgrade Cost/ItemList"
@onready var upgrade_button: Button = $VBoxContainer/Upgrade
@onready var name_label: Label = $VBoxContainer/Name
@onready var option_button: OptionButton = $VBoxContainer/OptionButton
@onready var contained_items_list: VBoxContainer = $"VBoxContainer/Contained Items/ItemList"
@onready var repair_button = $VBoxContainer/Repair
@onready var upgrade_cost = $"VBoxContainer/Upgrade Cost"
@onready var upgrade_cost_title = $"VBoxContainer/Upgrade Cost Title"
@onready var contained_items_title = $"VBoxContainer/Contained Items Title"
@onready var contained_items = $"VBoxContainer/Contained Items"
@onready var craft_cost_title = $"VBoxContainer/Craft Cost Title"
@onready var craft_cost = $"VBoxContainer/Craft Cost"
@onready var craft_cost_list = $"VBoxContainer/Craft Cost/ItemList"

const COSTS = "upgrade_costs"
const INFO = "info"

var machine : Machine;
var max_level : int;

func _ready():
	source.resized.connect(_sync_size)
	upgrade_button.pressed.connect(_upgrade)
	option_button.item_selected.connect(_set_recipe)

func _process(_delta):
	_sync_size()

func set_machine(machine_to_be_set):
	if machine_to_be_set == null: return
	machine = machine_to_be_set
	if not machine.storage_modified.is_connected(_update_res):
		machine.storage_modified.connect(_update_res)
	_update_res()

var row_scene = preload("res://Inventory/ItemRow.tscn")

func _update_res():
	if machine == null:
		return

	var machine_json = Machinejson.parsed_data.get(machine.name)
	if machine_json == null:
		return

	max_level = machine_json.get("max_level", 0)
	repair_button.visible = machine.is_damaged
	handle_option_button(machine_json)

	var base = machine.name.capitalize() + " Lv. " + str(machine.level)
	var on_max_level = machine.level == max_level
	if on_max_level:
		base += " (MAX)"
		upgrade_button.visible = false
	else:
		upgrade_button.visible = true

	name_label.text = base

	for i in upgrade_cost_list.get_children(): i.queue_free()
	for i in contained_items_list.get_children(): i.queue_free()
	for i in craft_cost_list.get_children(): i.queue_free()

	var upgrade_costs = machine_json.get(COSTS, {})
	var level_costs = upgrade_costs.get(str(machine.level), [])
	for item in level_costs:
		var row = row_scene.instantiate()
		var item_type = GlobalInventory.convert_name_to_enum(item["id"])
		var item_name = GlobalInventory.item_as_displayed_name(item_type)
		var item_count = item["amount"]
		row.setup(item_name, UID.ITEM_TEXTURES[item_type], item_count)
		upgrade_cost_list.add_child(row)
	
	var hide_upgrade_cost = on_max_level or level_costs.size() == 0
	upgrade_cost.visible = not hide_upgrade_cost
	upgrade_cost_title.visible = not hide_upgrade_cost
	
	var received_items_snapshot = machine.received_items.duplicate()
	for item in received_items_snapshot.keys():
		var row = row_scene.instantiate()
		var item_name = GlobalInventory.item_as_displayed_name(item)
		row.setup(item_name, UID.ITEM_TEXTURES[item], received_items_snapshot.get(item))
		contained_items_list.add_child(row)
	
	var holds_items = received_items_snapshot.size() > 0
	contained_items_title.visible = holds_items
	contained_items.visible = holds_items
	
	handle_craft_cost()
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
	target.size = Vector2(source.size.x, option_button.position.y)
	target.position = source.position
	
func _set_recipe(index: int):
	var text = option_button.get_item_text(index)
	machine.recipe = text
	MachineData.craft_item(machine)
	_update_res()

func _on_repair_pressed():
	MachineData.is_in_minigame = true
	var minigame_scene = UID.SCN_WELDING
	if machine.machine_type == MachineData.MachineType.Smelter: minigame_scene = UID.SCN_PIPES
	var minigame_instance = minigame_scene.instantiate()
	minigame_instance.to_be_repaired_machine = machine
	get_parent().add_child(minigame_instance)
	hide()

func handle_option_button(machine_json):
	var options = ["No Recipe"]
	var recipes = machine_json.get("recipes", [])
	var is_crafter = machine.machine_type == MachineData.MachineType.Crafter
	if is_crafter: recipes = machine_json.get("crafting_results", [])
	for i in range(recipes.size()):
		var recipe_result = recipes[i]
		if not is_crafter:
			#recipe_result = GlobalInventory.item_as_displayed_name(GlobalInventory.convert_name_to_enum(recipe_result))
			options.append(recipe_result)
			continue
		
		if i >= machine.level: break
		for craftable in recipe_result:
			#var displayed_name = GlobalInventory.get_displayed(craftable)
			options.append(craftable)

	option_button.clear()
	for i in options:
		option_button.add_item(i)
	
	if machine.recipe != "":
		option_button.select(options.find(machine.recipe))

func handle_craft_cost():
	var can_see_craft_cost = machine.machine_type == MachineData.MachineType.Crafter and option_button.selected > 0
	craft_cost_title.visible = can_see_craft_cost
	craft_cost.visible = can_see_craft_cost
	var craft_cost = machine.get_craft_cost()
	if craft_cost == null: return
	for required_item in craft_cost:
		var item_name = required_item["id"]
		var required_amount = required_item["amount"]
		var row = row_scene.instantiate()
		var item_type = GlobalInventory.convert_name_to_enum(item_name)
		row.setup(item_name, UID.ITEM_TEXTURES[item_type], required_amount)
		craft_cost_list.add_child(row)
