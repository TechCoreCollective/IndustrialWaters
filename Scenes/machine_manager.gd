extends Node

@onready var machine_status: Control = $"../MachineStatus"
@onready var panel_2: Panel = $"../Panel2"

var time = 0

func _ready() -> void:
	pass

const time_to_make_resource = 1
var break_time = 0

func _process(delta: float) -> void:
	time += delta

	if time > time_to_make_resource:
		var machines_copy = MachineData.placed_machines.duplicate()
		for machine in machines_copy:
			if machine == null:
				continue

			if machine.machine_type in MachineData.Generators and machine.recipe != "":
				if not machine.data.has(machine.recipe):
					machine.data[machine.recipe] = 0

				machine.data[machine.recipe] += machine.multiplier
				var item_type = GlobalInventory.convert_name_to_enum(machine.recipe)
				if item_type != GlobalInventory.ItemType.None:
					MachineData.resources_produced(machine, item_type)

			if machine.machine_type in MachineData.Crafters and machine.recipe != "":
				if not machine.data.has(machine.recipe):
					machine.data[machine.recipe] = 0

				var machine_json = Machinejson.parsed_data.get(machine.name)
				if machine_json == null or not machine_json.has("requirements"):
					continue
				var requirements = machine_json.get("requirements")
				if requirements == null or not requirements.has(machine.recipe):
					continue
				var resources_needed = requirements.get(machine.recipe)

				for i in resources_needed:
					i["amount"] *= machine.multiplier

				print(resources_needed)

				if Utils.remove_resources_safe_machine(resources_needed, machine):
					machine.data[machine.recipe] += machine.multiplier

				for i in resources_needed:
					i["amount"] /= machine.multiplier


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
