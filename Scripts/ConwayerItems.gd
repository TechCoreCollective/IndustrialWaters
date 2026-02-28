extends Node2D

@onready var grid_root = $".."
@onready var conveyor_belts = grid_root.get_node("Conveyor Belts")

func add_associated_sprite(conway_item: ConwayItem):
	var sprite = Sprite2D.new()
	add_child(sprite)
	match conway_item.item_type:
		GlobalInventory.ItemType.CopperOre: sprite.texture = UID.IMG_COPPER_ORE_ITEM
		GlobalInventory.ItemType.Diamond: sprite.texture = UID.IMG_DIAMOND_ITEM
		GlobalInventory.ItemType.IronOre: sprite.texture = UID.IMG_IRON_ORE_ITEM
	conway_item.associated_sprite = sprite

const one_tile_duration: float = 0.25

func get_size_of_path(conway_item: ConwayItem):
	return MachineData.active_conwayerors[conway_item.conway_path_index].size()

func update_conwayer_items(delta):
	for conway_item: ConwayItem in MachineData.traveling_conway_items:
		if conway_item.associated_sprite == null: add_associated_sprite(conway_item)
		var size_of_path = get_size_of_path(conway_item)
		var full_path_travel_duration: float = one_tile_duration * size_of_path
		var travel_progress = conway_item.time_on_belt / full_path_travel_duration
		if travel_progress < 1: conway_item.time_on_belt += delta
		handle_conwayer_item(conway_item, travel_progress)
		if travel_progress >= 1: send_item_to_machine(conway_item)

func handle_conwayer_item(conway_item: ConwayItem, progress: float):
	var conway_item_pos := get_current_item_pos(conway_item, progress)
	var item_world_pos = grid_root.get_world_position(conway_item_pos + Vector2.ONE / 2)
	conway_item.world_tile = conway_item_pos
	conway_item.associated_sprite.position = item_world_pos

func get_current_item_pos(conway_item: ConwayItem, progress: float) -> Vector2:
	var used_path = MachineData.conway_path_points[conway_item.conway_path_index]
	var size_of_path = get_size_of_path(conway_item)
	var distance_travelled = size_of_path * progress
	if progress >= 1: return used_path[used_path.size()-1]
	var first_tile = used_path[0]
	var number_of_points = used_path.size()
	if number_of_points == 1: return first_tile
	
	var previous_tile = first_tile
	var size_of_current_sub_path = 0
	var segment_index = 0
	var segment_sizes_up_to_point: Array = []
	for i in range(1, number_of_points):
		var current_tile = used_path[i]
		var segment_size = current_tile - previous_tile
		var manhattan_dist = abs(segment_size.x) + abs(segment_size.y)
		size_of_current_sub_path += manhattan_dist
		
		segment_sizes_up_to_point.append(size_of_current_sub_path)
		if distance_travelled <= size_of_current_sub_path:
			segment_index = i - 1
			break
		previous_tile = current_tile
	
	var end_segment_distance = size_of_current_sub_path
	var start_segment_distance = 0 if segment_index == 0 else segment_sizes_up_to_point[segment_index-1]
	var local_progress: float = inverse_lerp(start_segment_distance, end_segment_distance, distance_travelled)
	
	var start_segment_pos: Vector2 = used_path[segment_index]
	var end_segment_pos: Vector2 = used_path[segment_index+1]
	var resulting_pos = lerp(start_segment_pos, end_segment_pos, local_progress)
	if local_progress > 1: return used_path[used_path.size()-1]
	return resulting_pos

func send_item_to_machine(conway_item: ConwayItem):
	for machine: Machine in MachineData.placed_machines:
		var result = conveyor_belts.does_machine_connect_to_placed(conway_item.world_tile, machine)
		if result == null or result == false: continue
		if not conway_item.item_type in machine.received_items:
			machine.received_items[conway_item.item_type] = 0
		machine.received_items[conway_item.item_type] += 1
		conway_item.associated_sprite.queue_free()
		MachineData.traveling_conway_items.erase(conway_item)
		break
