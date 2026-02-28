extends Control

@onready var button: Button = $	Button

var item_name: String

var names = {
	"solid_drill": MachineData.MachineType.DrillSolid,
	"liquid_drill": MachineData.MachineType.DrillLiquid,
	"smelter": MachineData.MachineType.Smelter,
	"manufactor": MachineData.MachineType.Manufactor,
	"collector": MachineData.MachineType.Collector,
	"conveyor": MachineData.MachineType.ConveyorBelt
}

@export var sol = preload("res://icons/copper_ore.png")
@export var liq = preload("res://Textures/OilDrillIcon.png")
@export var smelt =  preload("res://Textures/SmelterIcon.png")

var textures = {
	"solid_drill": sol,
	"liquid_drill": liq,
	"smelter": smelt	
}

func _ready() -> void:
	button.pressed.connect(_craft)

func setup(name: String):
	item_name = name
	$VBoxContainer/Icon.texture = textures.get(name)
	$VBoxContainer/MachineName.text = name
	
func _craft():
	var cost = Machinejson.parsed_data.get(item_name).get("craft_cost")
	
	if Utils.remove_resources_safe(cost):
		MachineData.obtainedMachines[names.get(item_name)] += 1
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("MachineUi").update_ui()
		# i was here - honza
