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

var inventory: Dictionary[ItemType, int] = {}
signal contents_changed

func name_to_enum_generic_convert(element_name: String, used_enum: Dictionary) -> int:
	var pascal_case_name = element_name.to_pascal_case()
	if not pascal_case_name in used_enum: return -1
	return used_enum[pascal_case_name]

func enum_to_name_generic_convert(element_type: int, used_enum: Dictionary) -> String:
	if not element_type in used_enum.values(): return ""
	var enum_as_str: String = used_enum.find_key(element_type)
	var result = enum_as_str.to_snake_case()
	return result

func name_as_displayed_generic(item_type: int, used_enum: Dictionary) -> String:
	var name_in_snake_case = enum_to_name_generic_convert(item_type, used_enum)
	return get_displayed(name_in_snake_case)

func get_displayed(name_in_snake_case: String) -> String:
	var result = ""
	var make_proceeding_upper = true
	for ch in name_in_snake_case:
		if ch == '_': result += ' '
		else: result += ch.to_upper() if make_proceeding_upper else ch
		make_proceeding_upper = ch == '_'
	return result

func convert_name_to_enum(item_name: String) -> ItemType: return name_to_enum_generic_convert(item_name, ItemType)
func convert_enum_to_name(item_name: ItemType) -> String: return enum_to_name_generic_convert(item_name, ItemType)
func item_as_displayed_name(item_type: ItemType) -> String: return name_as_displayed_generic(item_type, ItemType)

func add_item(item_type: ItemType, count: int):
	if item_type == ItemType.None: return
	if not item_type in inventory.keys(): inventory[item_type] = 0
	inventory[item_type] += count
	contents_changed.emit()
