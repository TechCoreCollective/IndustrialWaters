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
var title_screen_on := true

@onready var background = $Background
@onready var seperator_root = $"Seperator Bars"
@onready var dragged_icon = $DraggedIcon
@onready var affected_tiles = $AffectedTiles
@onready var machines_root = $Machines
@onready var conveyor_root = $"Conveyor Belts"
@onready var conwayer_items = $"Conwayer Items"
@onready var logo = $Logo
@onready var overlay = $Overlay
@onready var play_game_button = $"Play Game Button"
@onready var machine_ui_root = $MachineUi
@onready var task_ui = $TaskUI
@onready var version_number = $"Version Number"

var seperator_rects: Array[ColorRect]

func _ready():
	MachineData.drag_start.connect(start_to_drag)
	MachineData.drag_end.connect(end_dragging)

var previous_frame_had_display_event := false

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed(): return
	handle_zoom_event(event)
	handle_offset_event()

const minimum_zoom = 0.05
const maximum_zoom = 5

func handle_zoom_event(event: InputEvent):
	if not event is InputEventMouseButton: return
	var previous_zoom = grid_zoom
	if event.button_index == MOUSE_BUTTON_WHEEL_UP: grid_zoom *= zoom_change
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: grid_zoom /= zoom_change
	grid_zoom = clamp(grid_zoom, minimum_zoom, maximum_zoom)
	if previous_zoom != grid_zoom:
		previous_frame_had_display_event = true
		display_scene()

func terminating_drag_and_drop():
	return Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("cancel_drop")

var current_frame = 0
const conway_items_refresh_rate = 2

func _process(delta):
	current_frame += 1
	update_window_size()
	if title_screen_on:
		logo.size.x = current_window_size.x
		overlay.size = current_window_size
		play_game_button.position.x = current_window_size.x / 2 - play_game_button.size.x / 2 * play_game_button.scale.x
	
	background.size = current_window_size
	if previous_window_size != current_window_size: display_scene()
	dragged_icon.position = get_global_mouse_position()
	conveyor_root.handle_conveyor_belts()
	if current_frame % conway_items_refresh_rate == 0 or previous_frame_had_display_event:
		conwayer_items.update_conwayer_items(delta)
	previous_frame_had_display_event = false
	if terminating_drag_and_drop():
		end_dragging()
		MachineData.drag_ended_prematurely = true
	handle_deletions()
	make_affected_tiles_visible()
	if MachineData.dragged_item != GlobalInventory.ItemType.None: display_machines()

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

const offset_change_multiplier = 0.3

func handle_offset_event():
	var offset_change: Vector2
	if Input.is_action_pressed("move_left"): offset_change.x += 1
	if Input.is_action_pressed("move_right"): offset_change.x -= 1
	if Input.is_action_pressed("move_up"): offset_change.y += 1
	if Input.is_action_pressed("move_down"): offset_change.y -= 1
	if offset_change == Vector2.ZERO: return
	var offset_used_change = offset_change / grid_zoom * offset_change_multiplier
	grid_offset += offset_used_change
	previous_frame_had_display_event = true
	display_scene()

func get_hovered() -> Vector2i:
	var mouse_pos = get_viewport().get_mouse_position()
	var unoffseted = mouse_pos / Vector2(space_between_bars)
	var result = unoffseted - grid_offset
	result = Vector2i(floor(result.x), floor(result.y))
	return result

func start_to_drag():
	if MachineData.is_ui_open(): return
	if MachineData.dragged_item != GlobalInventory.ItemType.None:
		dragged_icon.texture = UID.ITEM_TEXTURES[MachineData.dragged_item]
	else: dragged_icon.update_type(MachineData.dragged_type)
	
	MachineData.drag_ended_prematurely = false
	make_affected_tiles_visible()

func end_dragging():
	MachineData.dragged_type = MachineData.MachineType.None
	MachineData.dragged_item = GlobalInventory.ItemType.None
	dragged_icon.update_type(MachineData.MachineType.None)
	affected_tiles.hide()
	var stop_drag = is_placement_invalid() or terminating_drag_and_drop() or\
		MachineData.drag_ended_prematurely or MachineData.is_ui_open()
	
	if stop_drag:
		display_machines()
		return
	
	var dragged_machine = MachineData.previous_dragged != MachineData.MachineType.None
	if dragged_machine:
		var added_machine = Machine.ctor(MachineData.previous_dragged, get_hovered())
		MachineData.manage_machine_damage_timer(added_machine)
		MachineData.placed_machines.append(added_machine)
	else: conveyor_root.place_lubricant_to_convayor(get_hovered())
	
	display_machines()

func make_affected_tiles_visible():
	var hovering_convayor_belt = MachineData.get_conwayer_at_pos(get_hovered()).machine_type == MachineData.MachineType.ConveyorBelt
	var dragging_lubricant = MachineData.dragged_item == GlobalInventory.ItemType.Lubricant
	var dragging_anything = MachineData.dragging_something()
	var are_affected_visible = (not dragging_lubricant or not hovering_convayor_belt) and dragging_anything
	
	affected_tiles.visible = are_affected_visible
	update_position_of_texture(Machine.ctor(MachineData.dragged_type, get_hovered()), affected_tiles)
	var use_invalid_color = is_placement_invalid() or MachineData.dragged_item != GlobalInventory.ItemType.None
	affected_tiles.color = invalid_placement_color if use_invalid_color else affected_tiles_color

const amount_of_conway_tiles = 6

func update_position_of_texture(machine: Machine, texture):
	var used_machine_size = MachineData.machine_sizes.get(machine.machine_type, Vector2.ONE)
	var upper_left_hovered = machine.place_position - Vector2i(used_machine_size / 2)
	texture.position = get_world_position(upper_left_hovered)
	
	if texture is Control: texture.size = get_target_size(used_machine_size)
	elif texture is Sprite2D: update_displayed_scale(texture, used_machine_size)

func update_displayed_scale(sprite: Sprite2D, machine_size: Vector2):
	var sprite_scale = get_target_size(machine_size) / sprite.texture.get_size()
	sprite_scale = Vector2(sprite_scale.x * amount_of_conway_tiles, sprite_scale.y)
	sprite.scale = sprite_scale

func get_target_size(machine_size: Vector2): return machine_size * Vector2(space_between_bars)

func get_world_position(tile_pos) -> Vector2:
	var result = Vector2(tile_pos) * space_between_bars
	result += Vector2(grid_offset) * Vector2(space_between_bars)
	return result

var machine_arr: Array
const lubricant_hover_color := Color("58ffd2ff")

func display_machines():
	reset_machine_textures()
	for machine: Machine in MachineData.placed_machines:
		var machine_node = TextureRect.new()
		machine_node.texture = MachineData.get_texture_from_type(machine.machine_type)
		if machine.machine_type == MachineData.MachineType.ConveyorBelt:
			machine_node = Sprite2D.new()
			machine_node.z_index = -1
			conveyor_root.display_conveyor_belt(machine, machine_node)
			machine_node.modulate = set_convayor_modulate(machine)
		else: update_position_of_texture(machine, machine_node)
		var warning_node = TextureRect.new()
		if machine.is_damaged: warning_node.texture = UID.IMG_WARNING
		warning_node.size = space_between_bars
		machine_node.add_child(warning_node)
		machines_root.add_child(machine_node)
		machine_arr.append(machine_node)

func set_convayor_modulate(machine: Machine):
	var hovered_tile = get_hovered()
	var is_hovering_with_lubricant = hovered_tile == machine.place_position and MachineData.dragged_item == GlobalInventory.ItemType.Lubricant
	if is_hovering_with_lubricant: return lubricant_hover_color
	
	var start_color = Color.WHITE
	var end_color: Color
	var start_speed_multiplier = 1
	var end_speed_multiplier = 0
	for lubricant_limit in MachineData.lubricant_convayor_colors.keys():
		var current_color = MachineData.lubricant_convayor_colors[lubricant_limit]
		end_color = current_color
		end_speed_multiplier = lubricant_limit
		if lubricant_limit > machine.conway_speed_multiplier: break
		start_color = current_color
		start_speed_multiplier = lubricant_limit
	
	var modulate_weight = inverse_lerp(start_speed_multiplier-1, end_speed_multiplier-1, machine.conway_speed_multiplier-1)
	if start_speed_multiplier == end_speed_multiplier: modulate_weight = 1
	var result_modulate = start_color.lerp(end_color, modulate_weight)
	return result_modulate

func reset_machine_textures():
	for machine in machine_arr:
		machine.queue_free()
	machine_arr.clear()

func is_placement_invalid():
	if MachineData.previous_dragged != MachineData.MachineType.None: return is_machine_placement_invalid()
	return is_item_placement_invalid()

func is_machine_placement_invalid():
	var hovered_tile = get_hovered()
	var hovered_rect = Machine.ctor(MachineData.previous_dragged, hovered_tile).get_rect()
	for machine: Machine in MachineData.placed_machines:
		var machine_rect = machine.get_rect()
		if machine_rect.intersects(hovered_rect): return true
	return false

func is_item_placement_invalid():
	var hovered_tile = get_hovered()
	var hovered_convayor = MachineData.get_conwayer_at_pos(hovered_tile)
	match MachineData.previous_dragged_item:
		GlobalInventory.ItemType.Lubricant: return hovered_convayor.machine_type != MachineData.MachineType.ConveyorBelt
	return true

const allow_deletions = false

func handle_deletions():
	if not allow_deletions or not Input.is_action_pressed("delete_machine"): return
	var hovered_tile = get_hovered()
	for machine: Machine in MachineData.placed_machines:
		var machine_rect = machine.get_rect()
		if not machine_rect.has_point(hovered_tile): continue
		if machine.machine_type != MachineData.MachineType.ConveyorBelt: handle_deleted_machine(machine)
		else: handle_delete_conwayer_belt(machine)
		MachineData.placed_machines.erase(machine)
		display_scene()
		break

func handle_deleted_machine(machine_to_be_deleted: Machine):
	var deleted_items = []
	for i in range(MachineData.traveling_conway_items.size()):
		var item: ConwayItem = MachineData.traveling_conway_items[i]
		if item.creation_machine.place_position == machine_to_be_deleted.place_position:
			item.associated_sprite.queue_free()
			deleted_items.append(item)
	for item: ConwayItem in deleted_items:
		MachineData.traveling_conway_items.erase(item)

func handle_delete_conwayer_belt(conway: Machine):
	var originally_in_index: int
	for index in MachineData.active_conwayerors.keys():
		var path = MachineData.active_conwayerors.values()[index]
		if conway.place_position in path:
			originally_in_index = index
			break
	MachineData.active_conwayerors.erase(originally_in_index)
	var neighbours = conveyor_root.get_neighbouring_tiles(conway.place_position)
	added_neighbours_since_delete = [conway.place_position]
	for neigh in neighbours:
		MachineData.highest_conwayor_index += 1
		var neigh_pos = conway.place_position + neigh
		MachineData.active_conwayerors[MachineData.highest_conwayor_index] = [neigh_pos]
		add_neighbours_after_delete(MachineData.highest_conwayor_index, neigh_pos)

var added_neighbours_since_delete: Array[Vector2i]

func add_neighbours_after_delete(index, current_pos):
	var neighbours = conveyor_root.get_neighbouring_tiles(current_pos)
	for neigh in neighbours:
		var neigh_pos = current_pos + neigh
		if neigh_pos in added_neighbours_since_delete: continue
		MachineData.active_conwayerors[index].append(neigh_pos)
		added_neighbours_since_delete.append(neigh_pos)
		add_neighbours_after_delete(index, neigh_pos)

const start_game_wait = 0.25
var started_previously = false

func start_game():
	if started_previously: return
	create_tween().tween_property(overlay, "color:a", 0, start_game_wait)
	create_tween().tween_property(logo, "modulate:a", 0, start_game_wait)
	create_tween().tween_property(play_game_button, "modulate:a", 0, start_game_wait)
	create_tween().tween_property(machine_ui_root, "modulate:a", 1, start_game_wait)
	create_tween().tween_property(version_number, "modulate:a", 0, start_game_wait)
	started_previously = true
	await get_tree().create_timer(start_game_wait).timeout
	title_screen_on = false
	overlay.queue_free()
	logo.queue_free()
	play_game_button.queue_free()
	#task_ui.show()
