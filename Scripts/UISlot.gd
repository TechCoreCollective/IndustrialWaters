class_name UISlot
extends Node2D

@onready var main_sprite = $MainSprite
@onready var item_count = $ItemCount
@onready var icon_sprite = $Icon

var machine_type : MachineData.MachineType
var mouse_rect: Rect2

func _ready():
	icon_sprite.update_type(machine_type)
	update_item_count()

func update_item_count():
	var amount_of_machines = MachineData.obtainedMachines[machine_type]
	item_count.text = str(amount_of_machines)

func _process(_delta):
	modulate = Color.WHITE
	if MachineData.is_ui_open(): return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and machine_type == MachineData.dragged_type:
		MachineData.drag_end.emit()
		return
	if is_mouse_not_in_rect():
		if machine_type == MachineData.hovered_button_machine_type:
			MachineData.hovered_button_machine_type = MachineData.MachineType.None
		return
	modulate = Color.SKY_BLUE
	MachineData.hovered_button_machine_type = machine_type
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	MachineData.dragged_type = machine_type
	MachineData.previous_dragged = machine_type
	MachineData.drag_start.emit()

func make_rect():
	var texture_size = main_sprite.texture.get_size() * global_scale
	mouse_rect = Rect2(main_sprite.global_position - texture_size / 2, texture_size)

func is_mouse_not_in_rect():
	var mouse_pos = get_global_mouse_position()
	var bottom_right_bounds = mouse_rect.position + mouse_rect.size
	var upper_left_bounds = mouse_rect.position
	return mouse_pos.x < upper_left_bounds.x or mouse_pos.y < upper_left_bounds.y or\
		mouse_pos.x > bottom_right_bounds.x or mouse_pos.y > bottom_right_bounds.y
