extends Node2D

const GRID_WIDTH := 6
const GRID_HEIGHT := 3
const TILE_SIZE := 240
const START_POSITION := Vector2(-26, 82)

@export var straight_pipe: PackedScene
@export var turn_pipe: PackedScene
@export var straight_pipe_rotatable: PackedScene
@export var turn_pipe_rotatable: PackedScene

@export var straight_rotation_offset := 0
@export var corner_rotation_offset := 270

# - = straight horizontal
# | = straight vertical
# L J F 7 = turnes
var solution: Array[String] = [
	"-7  F-",
	" |  | ",
	" L--J "
]

# Vector2i(x, y)
var movable_tiles: Array[Vector2i] = [
	Vector2i(1,0),
	Vector2i(1,1),
	Vector2i(1,2),
	Vector2i(2,2),
	Vector2i(3,2),
	Vector2i(4,1),
	Vector2i(4,2),
	Vector2i(4,0)
]

var grid: Array = []

func _ready():
	randomize()
	generate_grid()
	#show_solution()

"""func _process(delta: float) -> void:
	if check_win():
		print("WIN!!!")
	else:
		print("not win")"""

func generate_grid():
	for y in range(GRID_HEIGHT):
		grid.append([])
		
		for x in range(GRID_WIDTH):
			var char = solution[y][x];
			
			if char == " " or char == '_':
				grid[y].append(null)
				continue
			
			var is_movable = Vector2i(x,y) in movable_tiles;
			
			var tile := create_tile_from_char(char, is_movable)
			add_child(tile)
			
			tile.position = START_POSITION + Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile.rotation_degrees = get_rotation_from_char(char)
			
			if is_movable:
				randomize_rotation(tile)
			
			grid[y].append(tile)

func show_solution():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = grid[y][x]
			if tile == null:
				continue
			
			var correct_rot = get_rotation_from_char(solution[y][x])
			tile.rotation_degrees = correct_rot

func create_tile_from_char(char, rotatable: bool) -> Node2D:
	match char:
		"-", "|":
			if rotatable:
				return straight_pipe_rotatable.instantiate()
			else:
				return straight_pipe.instantiate()
		"L", "J", "F", "7":
			if rotatable:
				return turn_pipe_rotatable.instantiate()
			else:
				return turn_pipe.instantiate()
		_:
			return null

func randomize_rotation(tile):
	var r := randi() % 4
	tile.rotation_degrees += r * 90

func get_rotation_from_char(char):
	match char:
		"-":
			return 0 + straight_rotation_offset
		"|":
			return 90 + straight_rotation_offset
		"L":
			return 0 + corner_rotation_offset
		"F":
			return 90 + corner_rotation_offset
		"7":
			return 180 + corner_rotation_offset
		"J":
			return 270 + corner_rotation_offset
		_:
			return 0

func normalize_angle(angle: float, isStraightPipe: bool  = false) -> int:
	var r: int = 180 if isStraightPipe else 360
	var a = (int)(round(angle)) % r
	while a < 0:
		a += 360
	return a

func check_win():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = grid[y][x]
			if tile == null:
				continue
			
			var char = solution[y][x]
			var isStraight = (char == "-" or char == "|")
			
			normalize_angle(tile.rotation_degrees)
			var current_rot = normalize_angle(tile.rotation_degrees, isStraight)
			var correct_rot = normalize_angle(get_rotation_from_char(solution[y][x]), isStraight)

			
			if current_rot != correct_rot:
				return false
	
	return true
