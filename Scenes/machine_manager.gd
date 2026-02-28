extends Node

@onready var machine_status: Control = $"../MachineStatus"

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	if time > 5:
		for machine in MachineData.placed_machines:
			if machine == null:
				continue
			
			if machine.machine_type in MachineData.Generators and machine.recipe != "":
				if not machine.data.has(machine.recipe):
					machine.data[machine.recipe] = 0
				
				machine.data[machine.recipe] += 1
				MachineData.resources_produced(machine, GlobalInventory.convert_name_to_enum(machine.recipe))
		
		time = 0
	
	var machine_info = MachineData.get_clicked_machine_info()
	
	if machine_info != null and Input.is_action_just_pressed("middle clicjk") and machine_info.name != "conveyor":
		machine_status.set_machine(machine_info)
		machine_status.visible = true
		var pos = get_viewport().get_mouse_position()
		machine_status.set_position(pos)
	
	if Input.is_action_just_pressed("Escape from Epstein Island"):
		machine_status.visible = false
