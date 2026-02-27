extends Node2D

var grid_zoom: float = 1
var grid_offset: Vector2

var previous_window_size: Vector2
var current_window_size: Vector2
const zoom_change = 1.1
const bar_dist = 100
const seperator_bar_color = Color("3777a5")
const bar_spacing = 0.25

@onready var seperator_root = $"Seperator Bars"

var seperator_rects: Array[ColorRect]

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed(): return
	handle_zoom_event(event)

func handle_zoom_event(event: InputEvent):
	if not event is InputEventMouseButton: return
	var previous_zoom = grid_zoom
	if event.button_index == MOUSE_BUTTON_WHEEL_UP: grid_zoom *= zoom_change
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: grid_zoom /= zoom_change
	if previous_zoom != grid_zoom: display_scene()

func _process(_delta):
	update_window_size()
	if previous_window_size != current_window_size: display_scene()

func update_window_size(): current_window_size = DisplayServer.window_get_size()

func free_all_previous():
	for seperator in seperator_rects:
		seperator.queue_free()
	seperator_rects.clear()

var space_between_bars: Vector2i

func display_scene():
	free_all_previous()
	update_window_size()
	previous_window_size = current_window_size
	space_between_bars = Vector2i(bar_dist * grid_zoom, bar_dist * grid_zoom)
	var amount_of_bars = Vector2i(current_window_size) / space_between_bars + Vector2i.ONE
	
	for x in range(amount_of_bars.x): display_bar(x, true)
	for y in range(amount_of_bars.y): display_bar(y, false)

func display_bar(pos: int, is_vertical: bool):
	var bar_pos_main = pos * space_between_bars.x if is_vertical else pos * space_between_bars.y
	var bar_pos = Vector2(bar_pos_main, 0) if is_vertical else Vector2(0, bar_pos_main)
	var bar_size_main = (space_between_bars.x if is_vertical else space_between_bars.y) * bar_spacing
	var bar_size = Vector2(bar_size_main, current_window_size.y) if is_vertical else\
		Vector2(current_window_size.x, bar_size_main)
	
	var bar_node = ColorRect.new()
	bar_node.color = seperator_bar_color
	bar_node.position = bar_pos
	bar_node.size = bar_size
	seperator_root.add_child(bar_node)
	seperator_rects.append(bar_node)
	
