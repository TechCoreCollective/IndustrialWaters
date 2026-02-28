extends Control

@onready var console: LineEdit = $"."
@onready var inventory: Inventory = GlobalInventory.get_node("Inventory")


var commands = {
	"give": _give
}

var item_name = "copper_ore"

var last_command = ""

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Send"):
		var split_command = console.text.strip_edges().split(" ")
		if split_command.size() == 0:
			return

		var command = split_command[0].to_lower()
		var args = split_command.slice(1) if split_command.size() > 1 else []

		if command in commands.keys():
			commands[command].call([args])
		else:
			print("Wrong Keyword:", command)

		last_command = console.text
		console.text = ""

func _give(args):
	if len(args) == 0:
		print("Usage: give <item_id> [amount]")
		return

	var item_id = args[0][0]
	var amount = int(args[0][1])
	
	print(item_id)
	print(amount)
	
	print("Giving:", amount, "x", item_id)
	inventory.add(item_id, amount)
