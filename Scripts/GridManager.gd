extends Node2D

var grid_zoom: float = 1
var grid_offset: Vector2

var previous_window_size: Vector2
var current_window_size: Vector2
const zoom_change = 1.1
const bar_dist = 100
const seperator_bar_color = Color("3575a4")
const bar_thickness = 0.15
const affected_tiles_color = Color("6193beff")
const invalid_placement_color = Color("bf7171ff")

@onready var background = $Background
@onready var seperator_root = $"Seperator Bars"
@onready var dragged_icon = $DraggedIcon
@onready var affected_tiles = $AffectedTiles
@onready var machines_root = $Machines
@onready var conveyor_root = $"Conveyor Belts"

var seperator_rects: Array[ColorRect]

func _ready():
	MachineData.drag_start.connect(start_to_drag)
	MachineData.drag_end.connect(end_dragging)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed(): return
	handle_zoom_event(event)
	handle_offset_event()

func handle_zoom_event(event: InputEvent):
	if not event is InputEventMouseButton: return
	var previous_zoom = grid_zoom
	if event.button_index == MOUSE_BUTTON_WHEEL_UP: grid_zoom *= zoom_change
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: grid_zoom /= zoom_change
	if previous_zoom != grid_zoom: display_scene()

func _process(_delta):
	update_window_size()
	background.size = current_window_size
	if previous_window_size != current_window_size: display_scene()
	dragged_icon.position = get_global_mouse_position()
	conveyor_root.handle_conveyor_belts()
	if MachineData.dragged_type == MachineData.MachineType.None: return
	make_affected_tiles_visible()

func update_window_size(): current_window_size = DisplayServer.window_get_size()

func free_all_previous():
	for seperator in seperator_rects:
		seperator.queue_free()
	seperator_rects.clear()

var space_between_bars: Vector2

func display_scene():
	free_all_previous()
	update_window_size()
	previous_window_size = current_window_size
	space_between_bars = Vector2(bar_dist * grid_zoom, bar_dist * grid_zoom)
	var amount_of_bars = current_window_size / space_between_bars + Vector2.ONE * 2
	
	for x in range(amount_of_bars.x): display_bar(x, true)
	for y in range(amount_of_bars.y): display_bar(y, false)
	display_machines()

func display_bar(pos: int, is_vertical: bool):
	var used_offset = grid_offset.x if is_vertical else grid_offset.y
	var used_space = space_between_bars.x if is_vertical else space_between_bars.y
	
	var used_pos_index: float = pos + fmod(used_offset, 1)
	var bar_pos_main = used_pos_index * used_space
	var bar_pos = Vector2(bar_pos_main, 0) if is_vertical else Vector2(0, bar_pos_main)
	
	var bar_size_main = used_space * bar_thickness
	var bar_size = Vector2(bar_size_main, current_window_size.y) if is_vertical else\
		Vector2(current_window_size.x, bar_size_main)
	
	var bar_node = ColorRect.new()
	bar_node.color = seperator_bar_color
	bar_node.position = bar_pos
	bar_node.size = bar_size
	bar_node.z_index = -2
	seperator_root.add_child(bar_node)
	seperator_rects.append(bar_node)

const offset_change_multiplier = 0.725

func handle_offset_event():
	var offset_change: Vector2
	if Input.is_action_pressed("move_left"): offset_change.x += 1
	if Input.is_action_pressed("move_right"): offset_change.x -= 1
	if Input.is_action_pressed("move_up"): offset_change.y += 1
	if Input.is_action_pressed("move_down"): offset_change.y -= 1
	if offset_change == Vector2.ZERO: return
	var offset_used_change = offset_change * grid_zoom * offset_change_multiplier
	grid_offset += offset_used_change
	display_scene()

func get_hovered() -> Vector2i:
	var mouse_pos = get_viewport().get_mouse_position()
	return Vector2i(mouse_pos / Vector2(space_between_bars) - grid_offset)

func start_to_drag():
	dragged_icon.update_type(MachineData.dragged_type)
	affected_tiles.show()
	make_affected_tiles_visible()

func end_dragging():
	dragged_icon.update_type(MachineData.MachineType.None)
	affected_tiles.hide()
	if is_placement_invalid(): return
	var added_machine = Machine.new()
	added_machine.machine_type = MachineData.previous_dragged
	added_machine.place_position = get_hovered()
	MachineData.placed_machines.append(added_machine)
	display_machines()

func make_affected_tiles_visible():
	update_position_of_texture(Machine.ctor(MachineData.dragged_type, get_hovered()), affected_tiles)
	affected_tiles.color = invalid_placement_color if is_placement_invalid() else affected_tiles_color

const amount_of_conway_tiles = 6

func update_position_of_texture(machine: Machine, texture):
	var used_machine_size = MachineData.machine_sizes[machine.machine_type]
	var upper_left_hovered = machine.place_position - Vector2i(used_machine_size / 2)
	var hovered_pos: Vector2 = Vector2(upper_left_hovered) * space_between_bars
	hovered_pos += Vector2(grid_offset) * Vector2(space_between_bars)
	texture.position = hovered_pos
	
	var target_size = used_machine_size * Vector2(space_between_bars)
	if texture is Control: texture.size = target_size
	elif texture is Sprite2D:
		var sprite_scale = target_size / texture.texture.get_size()
		sprite_scale = Vector2(sprite_scale.x * amount_of_conway_tiles, sprite_scale.y)
		texture.scale = sprite_scale

var machine_arr: Array

func display_machines():
	reset_machine_textures()
	for machine: Machine in MachineData.placed_machines:
		var machine_node = TextureRect.new()
		machine_node.texture = MachineData.get_texture_from_type(machine.machine_type)
		if machine.machine_type == MachineData.MachineType.ConveyorBelt:
			machine_node = Sprite2D.new()
			machine_node.z_index = -1
			conveyor_root.display_conveyor_belt(machine, machine_node)
		else: update_position_of_texture(machine, machine_node)
		machines_root.add_child(machine_node)
		machine_arr.append(machine_node)

func reset_machine_textures():
	for machine in machine_arr:
		machine.queue_free()
	machine_arr.clear()

func is_placement_invalid():
	var hovered_tile = get_hovered()
	var hovered_rect = Machine.ctor(MachineData.previous_dragged, hovered_tile).get_rect()
	for machine: Machine in MachineData.placed_machines:
		var machine_rect = machine.get_rect()
		if machine_rect.intersects(hovered_rect): return true
	return false
