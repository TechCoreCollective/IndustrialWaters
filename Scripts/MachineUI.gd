extends Control

@onready var gradient = $Gradient
@onready var grid_root = $".."
var ui_slots: Array[UISlot]

func _ready():
	MachineData.drag_end.connect(end_machine_drag)

func end_machine_drag():
	var new_machine_count = MachineData.obtainedMachines[MachineData.dragged_type] - 1
	if grid_root.is_placement_invalid(): new_machine_count += 1
	if new_machine_count <= 0: MachineData.obtainedMachines.erase(MachineData.dragged_type)
	else: MachineData.obtainedMachines[MachineData.dragged_type] = new_machine_count
	
	MachineData.previous_dragged = MachineData.dragged_type
	MachineData.dragged_type = MachineData.MachineType.None
	update_ui()

func _process(_delta):
	var previous_window_size = latest_window_size
	update_window_size()
	if previous_window_size == latest_window_size: return
	update_ui()

const ui_slot_scale = 4

func add_new_machine_ui(index) -> UISlot:
	var ui_slot = UID.SCN_UI_SLOT.instantiate()
	ui_slots.append(ui_slot)
	var used_type = MachineData.obtainedMachines.keys()[index]
	ui_slot.machine_type = used_type
	add_child(ui_slot)
	return ui_slot

func delete_all_ui_slots():
	for slot in ui_slots: slot.queue_free()
	ui_slots.clear()

var latest_window_size: Vector2
func update_window_size(): latest_window_size = DisplayServer.window_get_size()

const ui_slot_y_offset = 0.75
const ui_slot_gap = 1.25
const ui_slot_size = 325

func update_ui():
	delete_all_ui_slots()
	var machine_count = MachineData.obtainedMachines.size()
	var first_index: float = floor(-machine_count / 2)
	if machine_count % 2 == 0: first_index += 0.5
	for i in range(machine_count):
		var current_slot = add_new_machine_ui(i)
		var ui_slot_used_scale = latest_window_size.x / ui_slot_size
		current_slot.scale = Vector2(ui_slot_used_scale, ui_slot_used_scale)
		var ui_slot_size_used = current_slot.main_sprite.texture.get_size() * current_slot.scale
		current_slot.position.y = latest_window_size.y - ui_slot_size_used.y * ui_slot_y_offset
		var current_index = first_index + i
		var x_offset = ui_slot_size_used.x * current_index * ui_slot_gap
		current_slot.position.x = latest_window_size.x / 2 + x_offset
		current_slot.make_rect()
		if i == MachineData.MachineType.None: continue
	update_gradient()

func update_gradient():
	gradient.size = Vector2(latest_window_size.y, latest_window_size.x)
	gradient.position.y = latest_window_size.y
