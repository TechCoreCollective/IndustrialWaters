extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")
@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList
@onready var info_label: Label = $VBoxContainer/Info

var text = FileAccess.get_file_as_string("res://config/machines.json")
var parsed_data = JSON.parse_string(text)

const COSTS = "upgrade_costs"
const INFO = "info"

const NAME = "machine"
var level = 1

func _ready():
	source.resized.connect(_sync_size)
	_sync_size()
	_update_res()

func _update_res():
	var row_scene = load("res://Inventory/ItemRow.tscn")
	
	for i in item_list.get_children():
		i.queue_free()
	
	for item in parsed_data.get(NAME).get(COSTS).get(str(level)):
		var row = row_scene.instantiate()
		row.setup(inventory.get_item_from_id(item.get("id")).name, inventory.get_item_from_id(item.get("id")).icon, item.get("amount"))
		item_list.add_child(row)
	
	var info_panel = ""
	for info in parsed_data.get(NAME).get(INFO).get(str(level)):
		var text = info.get("id") + ": " + info.get("value")
		info_panel += text + "\n"
	
	info_label.text = info_panel

func _sync_size():
	target.size = source.size
	target.position = source.position
