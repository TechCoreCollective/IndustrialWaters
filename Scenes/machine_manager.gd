extends Node

@onready var machine_status: Control = $"../MachineStatus"
@onready var panel_2: Panel = $"../Panel2"
@onready var welding: Node2D = $"../Welding"

var time = 0

func _ready() -> void:
	pass

const time_to_make_resource = 1
var break_time = 0

var broken = false

func _process(delta: float) -> void:
	time += delta
	
	if time > time_to_make_resource:
		break_time += time
		for machine in MachineData.placed_machines:
			if machine == null or (broken and break_time >= 20):
				continue
			
			if machine.machine_type in MachineData.Generators and machine.recipe != "":
				if not machine.data.has(machine.recipe):
					machine.data[machine.recipe] = 0
				
				machine.data[machine.recipe] += machine.multiplier
				MachineData.resources_produced(machine, GlobalInventory.convert_name_to_enum(machine.recipe))
				
			if machine.machine_type in MachineData.Crafters and machine.recipe != "":
				if not machine.data.has(machine.recipe):
					machine.data[machine.recipe] = 0
				
				var resources_needed = Machinejson.parsed_data.get(machine.name).get("requirements").get(machine.recipe)
				
				for i in resources_needed:
					i["amount"] *= machine.multiplier
				
				print(resources_needed)
				
				if Utils.remove_resources_safe_machine(resources_needed, machine):
					machine.data[machine.recipe] += machine.multiplier
				
				for i in resources_needed:
					i["amount"] /= machine.multiplier
					
			if break_time >= 20 and not broken:
				welding.visible = true
				broken = true
				
		
		time = 0
	
	var machine_info = MachineData.get_clicked_machine_info()
	
	if machine_info != null and Input.is_action_just_pressed("middle clicjk") and machine_info.name != "conveyor":
		machine_status.set_machine(machine_info)
		machine_status.visible = true
		
		panel_2.visible = false
		
		var pos = get_viewport().get_mouse_position()
		machine_status.set_position(pos)
	
	if Input.is_action_just_pressed("Escape from Epstein Island"):
		machine_status.visible = false
