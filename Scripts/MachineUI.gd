extends Control

@onready var gradient = $Gradient
var ui_slots: Array[UISlot]

func _process(_delta):
	var previous_window_size = latest_window_size
	update_window_size()
	if previous_window_size == latest_window_size: return
	update_ui()

const ui_slot_scale = 4

func add_new_machine_ui() -> UISlot:
	var ui_slot = preload("uid://b66ronir3bmmc").instantiate()
	ui_slots.append(ui_slot)
	add_child(ui_slot)
	return ui_slot

func delete_all_ui_slots():
	for slot in ui_slots: slot.queue_free()
	ui_slots.clear()

var latest_window_size: Vector2
func update_window_size(): latest_window_size = DisplayServer.window_get_size()

const ui_slot_y_offset = 0.75
const ui_slot_gap = 1.25

func update_ui():
	delete_all_ui_slots()
	var machine_count = MachineData.obtainedMachines.size()
	var first_index: float = floor(-machine_count / 2)
	if machine_count % 2 == 0: first_index += 0.5
	for i in range(machine_count):
		var current_slot = add_new_machine_ui()
		current_slot.scale = Vector2(ui_slot_scale, ui_slot_scale)
		var ui_slot_size = current_slot.main_sprite.texture.get_size() * current_slot.scale
		current_slot.position.y = latest_window_size.y - ui_slot_size.y * ui_slot_y_offset
		var current_index = first_index + i
		var x_offset = ui_slot_size.x * current_index * ui_slot_gap
		current_slot.position.x = latest_window_size.x / 2 - x_offset
		current_slot.update_item_count(0)
	update_gradient()

func update_gradient():
	gradient.size = Vector2(latest_window_size.y, latest_window_size.x)
	gradient.position.y = latest_window_size.y
