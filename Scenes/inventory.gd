extends Control

@onready var search_bar: LineEdit = $VBoxContainer/SearchBar
@onready var item_list: VBoxContainer = $VBoxContainer/ScrollContainer/ItemList

var rows: Array = []

func _ready():
	search_bar.text_changed.connect(_on_search_changed)

	var icon = preload("res://icons/diamond.png")
	var row_scene = load("res://Inventory/ItemRow.tscn")

	for i in range(20):
		var row = row_scene.instantiate()
		row.setup("Diamond " + str(i), icon, i * 3)
		item_list.add_child(row)
		rows.append(row)
		
func _on_search_changed(text: String):
	text = text.to_lower()

	for row in rows:
		row.visible = row.item_name.to_lower().contains(text) or text.is_empty()
