extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")
@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var info_label: Label = $VBoxContainer/Info
@onready var button: Button = $VBoxContainer/Button
@onready var name_label: Label = $VBoxContainer/Name
@onready var option_button: OptionButton = $VBoxContainer/OptionButton

const COSTS = "upgrade_costs"
const INFO = "info"

var machine : Machine;
var max_level : int;

func _ready():
	source.resized.connect(_sync_size)
	button.pressed.connect(_upgrade)
	option_button.item_selected.connect(_set_recipe)
	
func set_machine(machine):
	self.machine = machine
	_update_res()

func _update_res():
	max_level = Machinejson.parsed_data.get(machine.name).get("max_level")
	
	var options = ["No Recipe"]
	
	options.append_array(Machinejson.parsed_data.get(machine.name).get("recipes"))
	
	option_button.clear()
	for i in options:
		option_button.add_item(i)
	
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
	
	for item in Machinejson.parsed_data.get(machine.name).get(COSTS).get(str(machine.level)):
		var row = row_scene.instantiate()
		row.setup(inventory.get_item_from_id(item.get("id")).name, inventory.get_item_from_id(item.get("id")).icon, item.get("amount"))
		item_list.add_child(row)
	
	_sync_size()
	
	var info_panel = ""
	for info in Machinejson.parsed_data.get(machine.name).get(INFO).get(str(machine.level)):
		var text = info.get("id") + ": " + info.get("value")
		info_panel += text + "\n"
	
	info_label.text = info_panel

func _upgrade():	
	
	var can_craft = Utils.remove_resources_safe(Machinejson.parsed_data.get(machine.name).get(COSTS).get(str(machine.level)))
	if not can_craft:
		return
	
	machine.level += 1
	
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
