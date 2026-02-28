extends Sprite2D

var machine_type: MachineData.MachineType

@export var invisible_on_start := false

func update_type(new_type):
	machine_type = new_type
	var icon_texture = null
	match machine_type:
		MachineData.MachineType.DrillSolid: icon_texture = UID.IMG_SOLID_DRILL_ICON
		MachineData.MachineType.DrillLiquid: icon_texture = UID.IMG_OIL_DRILL_ICON
		MachineData.MachineType.Smelter: icon_texture = UID.IMG_SMELTER_ICON
	texture = icon_texture

func _ready():
	if invisible_on_start: return
	update_type(machine_type)
