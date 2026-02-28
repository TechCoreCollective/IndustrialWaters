extends Node

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	for machine in MachineData.placed_machines:
		if machine == null:
			continue
		
		if machine.machine_type in MachineData.Generators and time > 1:
			time = 0
			if not machine.data.has(machine.recipe):
				machine.data[machine.recipe] = 0
			
			machine.data[machine.recipe] += 1
			MachineData.resources_produced(machine, GlobalInventory.convert_name_to_enum(machine.recipe))
