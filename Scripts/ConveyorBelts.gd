extends Node2D

@onready var grid = $".."

func handle_conveyor_belts():
	var can_place = MachineData.hovered_button_machine_type == MachineData.MachineType.None and\
		MachineData.dragged_type == MachineData.MachineType.None
	if Input.is_action_pressed("conveyor_place") and can_place: place_conveyor()

func place_conveyor():
	var place_tile = grid.get_hovered()
	var conveyor_tile = Machine.ctor(MachineData.MachineType.ConveyorBelt, place_tile)
	MachineData.previous_dragged = MachineData.MachineType.ConveyorBelt
	if is_conway_placement_invalid(): return
	MachineData.placed_machines.append(conveyor_tile)
	conway_tiles_by_pos[place_tile] = conveyor_tile
	conveyor_tile.conveyor_face_dir = determine_facing_direction(place_tile)
	grid.display_machines()

var conway_tiles_by_pos : Dictionary[Vector2i, Machine] = {}

func display_conveyor_belt(machine: Machine, sprite: Sprite2D):
	sprite.texture = UID.IMG_CONVEYOR_GRID
	sprite.hframes = grid.amount_of_conway_tiles
	sprite.frame_coords.x = machine.conveyor_face_dir
	sprite.centered = false
	grid.update_position_of_texture(machine, sprite)

func determine_facing_direction(place_tile: Vector2i, update_neighbours := true) -> Machine.ConveyorFaceDir:
	var neighbours = get_neighbouring_tiles(place_tile)
	if neighbours.size() == 0: return Machine.ConveyorFaceDir.Vertical
	var abs_neighbours := []
	for neighbour in neighbours:
		abs_neighbours.append(abs(neighbour))
	var resulting_dir := Machine.ConveyorFaceDir.Unknown
	match abs_neighbours:
		[Vector2i.RIGHT]: resulting_dir = Machine.ConveyorFaceDir.Horizontal
		[Vector2i.DOWN]: resulting_dir = Machine.ConveyorFaceDir.Vertical
	if neighbours.size() == 2:
		resulting_dir = check_for_two_connections(neighbours, abs_neighbours)
	if not update_neighbours: return resulting_dir
	var current_abs_neigh = neighbours_absolute_pos
	for tile_pos in current_abs_neigh:
		var neigh_new_dir = determine_facing_direction(tile_pos, false)
		conway_tiles_by_pos[tile_pos].conveyor_face_dir = neigh_new_dir
	return resulting_dir

func check_for_two_connections(neighbours, abs_neighbours):
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
		if machine.place_position == placement_pos: return true
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
		if connects_to_corner: continue
		if machine_rect.has_point(placement_pos): return true
	return false
