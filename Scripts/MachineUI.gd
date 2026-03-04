extends Control

@onready var gradient = $Gradient
@onready var grid_root = $".."
@onready var items = $Items
var ui_slots: Array[UISlot]

func _ready():
	MachineData.drag_end.connect(end_machine_drag)
	GlobalInventory.contents_changed.connect(update_ui)

func end_machine_drag():
	if MachineData.dragged_type >= 0:
		var new_machine_count = MachineData.obtainedMachines[MachineData.dragged_type] - 1
		if grid_root.is_placement_invalid() or MachineData.drag_ended_prematurely:
			new_machine_count += 1
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
	
	handle_items_ui()
	update_gradient()

func update_gradient():
	gradient.size = Vector2(latest_window_size.y, latest_window_size.x)
	gradient.position.y = latest_window_size.y

const items_ui_offset = 60
const items_ui_size_window_ratio = 265
const base_items_ui_scale = 2.8
const ui_item_y_offset_multiplier = 1.75

func handle_items_ui():
	for child in items.get_children(): child.queue_free()
	var ui_elements_displayed = 0
	for item_in_grid in GlobalInventory.items_seen_in_grid:
		if not item_in_grid in GlobalInventory.inventory: continue
		var item_amount = GlobalInventory.inventory[item_in_grid]
		var ui_slot_item = UID.SCN_UI_SLOT.instantiate()
		var items_ui_scale = latest_window_size.y / items_ui_size_window_ratio
		
		var used_offset = items_ui_offset * (items_ui_scale / base_items_ui_scale)
		ui_slot_item.position = Vector2(latest_window_size.x - used_offset, used_offset)
		ui_slot_item.position.y += used_offset * ui_elements_displayed * ui_item_y_offset_multiplier
		ui_slot_item.scale = Vector2(items_ui_scale, items_ui_scale)
		items.add_child(ui_slot_item)
		ui_slot_item.icon_sprite.texture = UID.ITEM_TEXTURES[item_in_grid]
		ui_slot_item.item_count.text = str(item_amount)
		ui_slot_item.make_rect()
		ui_elements_displayed += 1
