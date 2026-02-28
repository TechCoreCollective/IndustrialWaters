extends Node

@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")

func remove_resources_safe(required_materials) -> bool:
	for item in required_materials:
		if not inventory.contains(item.get("id"), item.get("amount")):
			return false
	
	for item in required_materials:
		inventory.remove(item.get("id"), item.get("amount"))
		
	return true
