# ItemRow.gd
extends Control

var item_name: String

func setup(name: String, icon: Texture2D, amount: int):
	item_name = name
	$HBoxContainer/Icon.texture = icon
	$HBoxContainer/ItemName.text = name
	$HBoxContainer/ItemCount.text = "x" + str(amount)
