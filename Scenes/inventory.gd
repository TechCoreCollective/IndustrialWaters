extends Control

@onready var search_bar: LineEdit = $VBoxContainer/SearchBar
@onready var item_list: VBoxContainer = $VBoxContainer/HBoxContainer/ScrollContainer/ItemList
@onready var machine_list: VBoxContainer = $VBoxContainer/HBoxContainer/ScrollContainer2/ItemList

var row_scene = load("res://Inventory/ItemRow.tscn")
var row_machine = load("res://Inventory/MachineRow.tscn")

@export var copper: String = "copper_ore"

var working_machines : Array[MachineData.MachineType] = [MachineData.MachineType.DrillSolid, MachineData.MachineType.DrillLiquid, MachineData.MachineType.Smelter]

var names = {
	MachineData.MachineType.DrillSolid : "solid_drill",
	MachineData.MachineType.DrillLiquid : "oil_drill",
	MachineData.MachineType.Smelter : "smelter",
	MachineData.MachineType.Crafter : "crafter",
	MachineData.MachineType.Collector : "collector",
	MachineData.MachineType.ConveyorBelt : "conveyor"
}

var rows: Array = []

func _ready():
	search_bar.text_changed.connect(_on_search_changed)
	GlobalInventory.contents_changed.connect(_contents_changed)
	_contents_changed()
		
func _contents_changed():
	for i in item_list.get_children():
		i.queue_free()
		
	for i in machine_list.get_children():
		i.queue_free()
	
	for item_type: GlobalInventory.ItemType in GlobalInventory.inventory.keys():
		if item_type == GlobalInventory.ItemType.None: continue
		var row = row_scene.instantiate()
		row.setup(GlobalInventory.item_as_displayed_name(item_type), UID.ITEM_TEXTURES[item_type], GlobalInventory.inventory[item_type])
		item_list.add_child(row)
		rows.append(row)

func _on_search_changed(text: String):
	text = text.to_lower()

	for row in rows:
		row.visible = row.item_name.to_lower().contains(text) or text.is_empty()
