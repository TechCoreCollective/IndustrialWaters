extends Node

enum ItemType {
	None,
	CopperOre,
	Diamond,
	IronOre,
	CopperIngot,
	IronIngot
}

@onready var database = $Inventory

func convert_name_to_enum(item_name: String) -> ItemType:
	match item_name:
		"diamond": return ItemType.Diamond
		"copper_ore": return ItemType.CopperOre
		"iron_ore": return ItemType.IronOre
		"copper_ingot": return ItemType.CopperIngot
		"iron_ingot": return ItemType.IronIngot
	return ItemType.None
	
func convert_enum_to_name(item_name: ItemType) -> String:
	match item_name:
		ItemType.Diamond: return "diamond"
		ItemType.CopperOre: return "copper_ore"
		ItemType.IronOre: return "iron_ore"
		ItemType.CopperIngot: return "copper_ingot"
		ItemType.IronIngot: return "iron_ingot"
	return ""

func add_item(item_type: ItemType, count: int):
	if item_type == ItemType.None:
		return
	database.add(convert_enum_to_name(item_type), count)
