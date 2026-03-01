extends Control

@onready var start: Button = $VBoxContainer/Start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect(_start)
	
func _start():	
	get_tree().change_scene_to_file("res://Scenes/PlacementGrid.tscn")
