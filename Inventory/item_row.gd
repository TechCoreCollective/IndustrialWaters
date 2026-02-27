extends Control

# Setup function to populate the row
func setup(item_name: String, icon: Texture2D, amount: int):
	$HBoxContainer/Icon.texture = icon
	$HBoxContainer/ItemName.text = item_name
	$HBoxContainer/ItemCount.text = "x" + str(amount)
