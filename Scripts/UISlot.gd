class_name UISlot
extends Node2D

var slot_index: int

@onready var main_sprite = $MainSprite
@onready var item_count = $ItemCount

func update_item_count(new_value): item_count.text = str(new_value)
