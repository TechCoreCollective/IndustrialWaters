extends Node2D

@onready var grid = $".."

func handle_conveyor_belts():
	var can_place = MachineData.hovered_button_machine_type == MachineData.MachineType.None and\
		MachineData.dragged_type == MachineData.MachineType.None and not MachineData.is_ui_open()
	if Input.is_action_pressed("conveyor_place") and can_place: place_conveyor()

func place_conveyor():
	var place_tile = grid.get_hovered()
	var conveyor_tile = Machine.ctor(MachineData.MachineType.ConveyorBelt, place_tile)
	MachineData.previous_dragged = MachineData.MachineType.ConveyorBelt
	if is_conway_placement_invalid(): return
	MachineData.placed_machines.append(conveyor_tile)
	conway_tiles_by_pos[place_tile] = conveyor_tile
	var direction_or_null = determine_facing_direction(place_tile)
	if direction_or_null == null:
		cancel_conveyor_placement(place_tile)
		return
	conveyor_tile.conveyor_face_dir = direction_or_null
	grid.display_machines()
	handle_active_conwayers(place_tile)

func cancel_conveyor_placement(place_tile: Vector2):
	conway_tiles_by_pos.erase(place_tile)
	MachineData.placed_machines.pop_back()

var conway_tiles_by_pos : Dictionary[Vector2i, Machine] = {}

func display_conveyor_belt(machine: Machine, sprite: Sprite2D):
	sprite.texture = UID.IMG_CONVEYOR_GRID
	sprite.hframes = grid.amount_of_conway_tiles
	sprite.frame_coords.x = machine.conveyor_face_dir
	sprite.centered = false
	grid.update_position_of_texture(machine, sprite)

func determine_facing_direction(place_tile: Vector2i, update_neighbours := true):
	var neighbours = get_neighbouring_tiles(place_tile)
	if neighbours.size() == 0: return Machine.ConveyorFaceDir.Vertical
	var abs_neighbours := []
	for neighbour in neighbours:
		abs_neighbours.append(abs(neighbour))
	var resulting_dir := Machine.ConveyorFaceDir.Unknown
	match abs_neighbours:
		[Vector2i.RIGHT]: resulting_dir = Machine.ConveyorFaceDir.Horizontal
		[Vector2i.DOWN]: resulting_dir = Machine.ConveyorFaceDir.Vertical
	if neighbours.size() >= 2:
		var dir_or_null = check_for_multiple_connections(neighbours, abs_neighbours)
		if dir_or_null == null: return null
		resulting_dir = dir_or_null
	if not update_neighbours: return resulting_dir
	var current_abs_neigh = neighbours_absolute_pos
	for tile_pos in current_abs_neigh:
		var neigh_new_dir = determine_facing_direction(tile_pos, false)
		if neigh_new_dir == null: return null
		conway_tiles_by_pos[tile_pos].conveyor_face_dir = neigh_new_dir
	return resulting_dir

func check_for_multiple_connections(neighbours, abs_neighbours):
	if has_all(neighbours, [Vector2i.DOWN, Vector2i.RIGHT]):
		return Machine.ConveyorFaceDir.UpRight
	if has_all(neighbours, [Vector2i.DOWN, Vector2i.LEFT]):
		return Machine.ConveyorFaceDir.UpLeft
	if has_all(neighbours, [Vector2i.UP, Vector2i.RIGHT]):
		return Machine.ConveyorFaceDir.DownRight
	if has_all(neighbours, [Vector2i.UP, Vector2i.LEFT]):
		return Machine.ConveyorFaceDir.DownLeft
	if abs_neighbours == [Vector2i.RIGHT, Vector2i.RIGHT]: return Machine.ConveyorFaceDir.Horizontal
	if abs_neighbours == [Vector2i.DOWN, Vector2i.DOWN]: return Machine.ConveyorFaceDir.Vertical
	return null

func has_all(arr: Array, compare: Array):
	for element in arr: if not element in compare: return false
	return true

var neighbours_absolute_pos := []

func get_neighbouring_tiles(place_tile: Vector2i) -> Array[Vector2i]:
	neighbours_absolute_pos = []
	var result: Array[Vector2i] = []
	for machine: Machine in MachineData.placed_machines:
		if machine.machine_type != MachineData.MachineType.ConveyorBelt: continue
		var machine_dist_from_place = machine.place_position - place_tile
		neighbours_absolute_pos.append(machine.place_position)
		var is_orthogonal_neighbour = get_neighbour_manhatatan_dist(machine_dist_from_place) == 1
		if not is_orthogonal_neighbour: continue
		result.append(machine_dist_from_place)
	return result

func get_neighbour_manhatatan_dist(dist_as_vec: Vector2i) -> int:
	return abs(dist_as_vec.x) + abs(dist_as_vec.y)

func is_conway_placement_invalid():
	var placement_pos = grid.get_hovered()
	for machine: Machine in MachineData.placed_machines:
		if machine.place_position == placement_pos and\
		machine.machine_type == MachineData.MachineType.ConveyorBelt: return true
	var neighbour_count = get_neighbouring_tiles(placement_pos).size()
	return neighbour_count == 0 and not does_connect_to_any_machine(placement_pos)

func does_connect_to_any_machine(placement_pos: Vector2):
	for machine: Machine in MachineData.placed_machines:
		var machine_rect = machine.get_rect()
		if machine.machine_type == MachineData.MachineType.ConveyorBelt: continue
		var rect_upper_left = machine_rect.position
		var rect_bottom_right = rect_upper_left + machine_rect.size - Vector2.ONE
		var connects_to_corner = placement_pos in\
			[rect_upper_left, rect_bottom_right,\
			Vector2(rect_upper_left.x, rect_bottom_right.y), Vector2(rect_bottom_right.x, rect_upper_left.y)]
			
		if connects_to_corner and not machine.machine_type in MachineData.corner_exception: continue
		var upper_left_y_delta = placement_pos.y - rect_upper_left.y
		if machine.machine_type in MachineData.machine_y_invalid and\
			upper_left_y_delta < MachineData.machine_y_invalid[machine.machine_type]:
			continue
		if machine_rect.has_point(placement_pos): return true
	return false

var conways_with_modified_index: Array[Vector2i]

func handle_active_conwayers(place_tile: Vector2i):
	conways_with_modified_index.clear()
	var current_conway = conway_tiles_by_pos[place_tile]
	var neighbour_count = get_neighbouring_tiles(place_tile).size()
	var conway_index = MachineData.highest_conwayor_index + 1
	if neighbour_count > 0: conway_index = determine_conwayer_index(place_tile)
	else: MachineData.highest_conwayor_index += 1
	
	if conway_index in MachineData.active_conwayerors:
		MachineData.active_conwayerors[conway_index].append(place_tile)
	else: MachineData.active_conwayerors[conway_index] = [place_tile]
	
	current_conway.conway_path_index = conway_index
	for i in range(1, neighbour_count):
		modify_neighbours_of_conway_index(place_tile, conway_index)
	create_conway_path_points()

func determine_conwayer_index(place_tile):
	var neighbours = get_neighbouring_tiles(place_tile)
	var first_neighbour_pos = neighbours[0] + place_tile
	var first_neighbour_data = MachineData.get_machine_by_pos(first_neighbour_pos)
	return first_neighbour_data.conway_path_index

func modify_neighbours_of_conway_index(current_tile: Vector2i, new_index: int):
	var neighbours = get_neighbouring_tiles(current_tile)
	for neighbour_delta in neighbours:
		var neighbour_pos = current_tile + neighbour_delta
		if neighbour_pos in conways_with_modified_index: continue
		var neighbour_data = MachineData.get_machine_by_pos(neighbour_pos)
		var previous_path_index = neighbour_data.conway_path_index
		neighbour_data.conway_path_index = new_index
		var previous_conway_index_arr = MachineData.active_conwayerors[previous_path_index]
		previous_conway_index_arr.erase(neighbour_pos)
		
		MachineData.active_conwayerors[new_index].append(neighbour_pos)
		conways_with_modified_index.append(neighbour_pos)
		modify_neighbours_of_conway_index(neighbour_pos, new_index)

func create_conway_path_points():
	MachineData.conway_path_points.clear()
	for path_index in MachineData.active_conwayerors.keys():
		var conway_path = MachineData.active_conwayerors[path_index]
		if conway_path.size() == 0: continue
		checked_conways_for_path.clear()
		var path_start = get_conway_path_start(conway_path)
		MachineData.conway_path_points[path_index] = [path_start]
		check_for_path_conway(path_index, path_start)

func get_conway_path_start(conway_path):
	for conway in conway_path:
		var neighbour_count = get_neighbouring_tiles(conway).size()
		if neighbour_count == 1: return conway
	return conway_path[0]

var checked_conways_for_path: Array[Vector2i]

func check_for_path_conway(path_index, current_conway):
	var neighbours = get_neighbouring_tiles(current_conway)
	var current_path = MachineData.conway_path_points[path_index]
	for neigh_delta in neighbours:
		var neighbour_pos = neigh_delta + current_conway
		if neighbour_pos in checked_conways_for_path: continue
		checked_conways_for_path.append(neighbour_pos)
		var neighbour_data = MachineData.get_machine_by_pos(neighbour_pos)
		var is_edge = not neighbour_data.conveyor_face_dir in [Machine.ConveyorFaceDir.Horizontal, Machine.ConveyorFaceDir.Vertical]
		if is_edge: current_path.append(neighbour_pos)
		check_for_path_conway(path_index, neighbour_pos)
	if neighbours.size() == 1 and not current_conway in current_path:
		current_path.append(current_conway)
