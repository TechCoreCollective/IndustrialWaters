extends Node

enum ItemType {
	None,
	CopperOre,
	Diamond,
	IronOre
}

@onready var database = $Inventory

func convert_name_to_enum(item_name: String) -> ItemType:
	match item_name:
		"diamond": return ItemType.Diamond
		"copper_ore": return ItemType.CopperOre
		"iron_ore": return ItemType.IronOre
	return ItemType.None

func add_item(item_type: ItemType, count: int):
	database.add()
