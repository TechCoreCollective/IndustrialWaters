extends Control

@onready var search_bar: LineEdit = $VBoxContainer/SearchBar
@onready var item_list: VBoxContainer = $VBoxContainer/HBoxContainer/ScrollContainer/ItemList
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")
@onready var machine_list: VBoxContainer = $VBoxContainer/HBoxContainer/ScrollContainer2/ItemList

var row_scene = load("res://Inventory/ItemRow.tscn")
var row_machine = load("res://Inventory/MachineRow.tscn")

@export var copper: String = "copper_ore"

var working_machines : Array[MachineData.MachineType] = [MachineData.MachineType.DrillSolid, MachineData.MachineType.DrillLiquid, MachineData.MachineType.Smelter]

var names = {
	MachineData.MachineType.DrillSolid : "solid_drill",
	MachineData.MachineType.DrillLiquid : "liquid_drill",
	MachineData.MachineType.Smelter : "smelter",
	MachineData.MachineType.Manufactor : "manufactor",
	MachineData.MachineType.Collector : "collector",
	MachineData.MachineType.ConveyorBelt : "conveyor"
}

var rows: Array = []

func _ready():
	search_bar.text_changed.connect(_on_search_changed)
	inventory.contents_changed.connect(_contents_changed)
	_contents_changed()
	
func _process(dt : float) -> void:
	if Input.is_action_just_pressed("add_item_a"):
		inventory.add(copper, 1)
		
func _contents_changed():
	for i in item_list.get_children():
		i.queue_free()
		
	for i in machine_list.get_children():
		i.queue_free()
	
	for item in inventory.stacks:
		if item.item_id != "":
			var row = row_scene.instantiate()
			row.setup(inventory.get_item_from_id(item.item_id).name, inventory.get_item_from_id(item.item_id).icon, item.amount)
			item_list.add_child(row)
			rows.append(row)
	
	for machine in working_machines:
		var id = names[machine]
		var row = row_machine.instantiate()
		row.setup(id)
		machine_list.add_child(row)
		rows.append(row)
			

func _on_search_changed(text: String):
	text = text.to_lower()

	for row in rows:
		row.visible = row.item_name.to_lower().contains(text) or text.is_empty()
