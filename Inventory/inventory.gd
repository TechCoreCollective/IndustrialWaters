extends Inventory

@onready var inventory: Inventory = $"."

@export var item_id : String = "iron"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		print("Inventory Stacks:")
		for item in inventory.stacks:
			if item.item_id != "":
				print(item.item_id," x ", item.amount)
			else:
				print("Empty")
				
	if Input.is_action_just_pressed("add_item_a"):
		inventory.add(item_id, 1)
