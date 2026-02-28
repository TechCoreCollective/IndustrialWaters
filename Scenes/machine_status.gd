extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")
@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var info_label: Label = $VBoxContainer/Info
@onready var button: Button = $VBoxContainer/Button
@onready var name_label: Label = $VBoxContainer/Name

var text = FileAccess.get_file_as_string("res://config/machines.json")
var parsed_data = JSON.parse_string(text)

const COSTS = "upgrade_costs"
const INFO = "info"

const NAME = "machine"
var level = 1
var max_level = parsed_data.get(NAME).get("max_level")

func _ready():
	source.resized.connect(_sync_size)
	button.pressed.connect(_upgrade)
	_sync_size()
	_update_res()

func _update_res():
	var base = NAME.capitalize() + " Lv. " + str(level)
	if level == max_level:
		base += " (MAX)"
		button.visible = false
		button.queue_free()
	
	name_label.text = base
	
	var row_scene = load("res://Inventory/ItemRow.tscn")
	
	for i in item_list.get_children():
		i.queue_free()
	
	for item in parsed_data.get(NAME).get(COSTS).get(str(level)):
		var row = row_scene.instantiate()
		row.setup(inventory.get_item_from_id(item.get("id")).name, inventory.get_item_from_id(item.get("id")).icon, item.get("amount"))
		item_list.add_child(row)
	
	_sync_size()
	
	var info_panel = ""
	for info in parsed_data.get(NAME).get(INFO).get(str(level)):
		var text = info.get("id") + ": " + info.get("value")
		info_panel += text + "\n"
	
	info_label.text = info_panel

func _upgrade():	
	for item in parsed_data.get(NAME).get(COSTS).get(str(level)):
		print(inventory.contains(item.get("id")))
		if not inventory.contains(item.get("id"), item.get("amount")):
			return
	
	for item in parsed_data.get(NAME).get(COSTS).get(str(level)):
		inventory.remove(item.get("id"), item.get("amount"))
	
	level += 1
	
	_update_res()

func _sync_size():
	target.size = source.size
	target.position = source.position
