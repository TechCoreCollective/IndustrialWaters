extends Node

enum ItemType {
	None,
	CopperOre,
	Diamond,
	IronOre,
	CopperIngot,
	IronIngot,
	Kelp,
	Mezholium,
	MezholiumStick,
	Glue
}

@onready var database = $Inventory

func convert_name_to_enum(item_name: String) -> ItemType:
	match item_name:
		"diamond": return ItemType.Diamond
		"copper_ore": return ItemType.CopperOre
		"iron_ore": return ItemType.IronOre
		"copper_ingot": return ItemType.CopperIngot
		"iron_ingot": return ItemType.IronIngot
		"kelp": return ItemType.Kelp
		"mezholium": return ItemType.Mezholium
		"mezholium_stick": return ItemType.MezholiumStick
		"glue": return ItemType.Glue
	return ItemType.None
	
func convert_enum_to_name(item_name: ItemType) -> String:
	match item_name:
		ItemType.Diamond: return "diamond"
		ItemType.CopperOre: return "copper_ore"
		ItemType.IronOre: return "iron_ore"
		ItemType.CopperIngot: return "copper_ingot"
		ItemType.IronIngot: return "iron_ingot"
		ItemType.Kelp: return "kelp"
		ItemType.Mezholium: return "mezholium"
		ItemType.MezholiumStick: return "mezholium_stick"
		ItemType.Glue: return "glue"
	return ""

func add_item(item_type: ItemType, count: int):
	if item_type == ItemType.None:
		return
	var item_name = convert_enum_to_name(item_type)
	if item_name == "" or item_name == null:
		return
	if database == null:
		return
	var item_definition = database.get_item_from_id(item_name)
	if item_definition == null:
		return
	database.add(item_name, count)
