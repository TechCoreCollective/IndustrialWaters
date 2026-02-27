extends Control

@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList


func _ready():
	
	for i in range(100):
		var row_scene = load("res://Inventory/ItemRow.tscn")  # PackedScene
		var row = row_scene.instantiate()                     # Node (HBoxContainer)
		
		# Now call setup on the instantiated node
		row.setup("Diamond", preload("res://icons/diamond.png"), 42)
		
		# Add to the UI somewhere
		item_list.add_child(row)
