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
	for item in required_materials:
		if not machine.received_items.has(GlobalInventory.convert_name_to_enum(item.get("id"))) or machine.received_items.get(GlobalInventory.convert_name_to_enum(item.get("id"))) < item.get("amount"):
			return false
	
	for item in required_materials:
		machine.received_items[int(GlobalInventory.convert_name_to_enum(item.get("id")))] -= item.get("amount")
		
	return true
