extends Node2D

@onready var welded_line = $WeldedLine
@onready var sparks = $Sparks
@onready var progress_label = $UI/ProgressLabel

var total_points = 0
var welded_points = 0
var is_welding = false

func _ready():
	total_points = $Checkpoints.get_child_count()
	update_ui()
	sparks.emitting = false

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	
	if Input.is_action_pressed("click"):
		is_welding = true
		sparks.emitting = true
		sparks.position = mouse_pos
		
		if welded_line.points.size() == 0 or mouse_pos.distance_to(welded_line.points[-1]) > 5:
			welded_line.add_point(mouse_pos)
		
		check_collision(mouse_pos)
	else:
		is_welding = false
		sparks.emitting = false

func check_collision(pos):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = pos
	parameters.collision_mask = 2
	parameters.collide_with_areas = true
	
	var result = space_state.intersect_point(parameters)
	
	for hit in result:
		var area = hit.collider
		if area is Area2D and area.visible:
			area.visible = false
			welded_points += 1
			update_ui()

func update_ui():
	var percentage = float(welded_points) / total_points * 100
	progress_label.text = "Welded: " + str(round(percentage)) + "%"
	
	if welded_points >= total_points:
		progress_label.text = "DONE! CRACK REPAIRED.";
