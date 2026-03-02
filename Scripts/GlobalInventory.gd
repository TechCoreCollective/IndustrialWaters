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
	Glue,
	CopperPlate,
	IronPlate
}

var inventory: Dictionary[ItemType, int] = {ItemType.CopperOre: 30}
signal contents_changed

func convert_name_to_enum(item_name: String) -> ItemType:
	var pascal_case_name = item_name.to_pascal_case()
	if not pascal_case_name in ItemType: return ItemType.None
	return ItemType[pascal_case_name]
	
func convert_enum_to_name(item_name: ItemType) -> String:
	if item_name == ItemType.None: return ""
	var enum_as_str : String = ItemType.find_key(item_name)
	return enum_as_str.to_snake_case()

func add_item(item_type: ItemType, count: int):
	if item_type == ItemType.None: return
	if not item_type in inventory.keys(): inventory[item_type] = 0
	inventory[item_type] += count
	contents_changed.emit()

func item_as_displayed_name(item_type: ItemType) -> String:
	var name_in_snake_case = convert_enum_to_name(item_type)
	var result = ""
	var make_proceeding_upper = true
	for ch in name_in_snake_case:
		if ch == '_': result += ' '
		else: result += ch.to_upper() if make_proceeding_upper else ch
		make_proceeding_upper = ch == '_'
	return result
