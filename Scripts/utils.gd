extends Node

@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")

func remove_resources_safe(required_materials) -> bool:
	for item in required_materials:
		if not inventory.contains(item.get("id"), item.get("amount")):
			return false
	
	for item in required_materials:
		inventory.remove(item.get("id"), item.get("amount"))
		
	return true
	
func remove_resources_safe_machine(required_materials, machine : Machine) -> bool:
	var received_items_snapshot = machine.received_items.duplicate()
	for item in required_materials:
		var item_enum = GlobalInventory.convert_name_to_enum(item.get("id"))
		if not received_items_snapshot.has(item_enum) or received_items_snapshot.get(item_enum) < item.get("amount"):
			return false

	for item in required_materials:
		machine.received_items[int(GlobalInventory.convert_name_to_enum(item.get("id")))] -= item.get("amount")

	return true
