extends Node

func remove_resources_safe(required_materials) -> bool:
	for item in required_materials:
		var item_type := GlobalInventory.convert_name_to_enum(item["id"])
		var contains_item = item_type in GlobalInventory.inventory
		if not contains_item: return false
		GlobalInventory.inventory[item_type] -= item["amount"]
		GlobalInventory.contents_changed.emit()
	return true
	
func remove_resources_safe_machine(required_materials, machine : Machine) -> bool:
	var received_items_snapshot = machine.received_items.duplicate()
	for item in required_materials:
		var item_enum = GlobalInventory.convert_name_to_enum(item.get("id"))
		if not received_items_snapshot.has(item_enum) or received_items_snapshot.get(item_enum) < item.get("amount"):
			return false

	for item in required_materials:
		machine.received_items[int(GlobalInventory.convert_name_to_enum(item.get("id")))] -= item.get("amount")
		machine.storage_modified.emit()

	return true
