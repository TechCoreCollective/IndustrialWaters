extends Node

@onready var panel_2: Panel = $"../Panel2"
@onready var machine_status: Control = $"../MachineStatus"
@onready var task_ui: Control = $"../TaskUI"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		panel_2.visible = !panel_2.visible
		machine_status.visible = false
	
	if Input.is_action_just_pressed("open_tasksk"):
		task_ui.visible = !task_ui.visible
