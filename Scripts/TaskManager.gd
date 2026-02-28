extends Node

const TASKS_PATH := "res://Config/tasks.json"

enum TaskType {
	SEND_MATERIALS,
	BUILD_MACHINE
}

var tasks: Array[Task] = []
var current_task_index: int = 0
var current_task_progress: int = 0

func _ready() -> void:
	load_tasks();
	current_task_index = SaveManager.current_task_index
	current_task_progress = SaveManager.current_task_progress

func load_tasks():
	if not FileAccess.file_exists(TASKS_PATH):
		push_error("Tasks JSON not found")
		return
		
	var file = FileAccess.open(TASKS_PATH, FileAccess.READ)
	if file == null:
		push_error("Cannot open tasks JSON")
		return
		
	var json_result = JSON.parse_string(file.get_as_text())
	file.close()
	
	for task_data in json_result:
		var task = Task.new()
		task.id = task_data["id"]
		task.name = task_data["name"]
		task.description = task_data["description"]
		task.required_amount = task_data.get("required_amount", 0)
		
		match task_data["type"]:
			"SendMaterials":
				task.type = TaskType.SEND_MATERIALS
				task.required_item_id = task_data["required_item_id"]
				
			"BuildMachine":
				task.type = TaskType.BUILD_MACHINE
				task.required_machine_type = MachineData.MachineType[task_data["required_machine_id"]]
		
		tasks.append(task)
	
	current_task_index = SaveManager.current_task_index;

func on_material_sent(item_id: String, amount: int):
	var task = get_current_task()
	if task == null or task.type != TaskType.SEND_MATERIALS or task.required_item_id != item_id:
		return
	
	current_task_progress += amount
	
	if current_task_progress >= task.required_amount:
		complete_current_task();
	else:
		SaveManager.save(current_task_index, current_task_progress);

func on_machine_built(machine_type: int):
	var task = get_current_task()
	if task == null or task.type != TaskType.BUILD_MACHINE or task.required_machine_type != machine_type:
		return
	
	current_task_progress += 1
	
	if current_task_progress >= task.required_amount:
		complete_current_task()

func complete_current_task():
	current_task_index += 1
	current_task_progress = 0
	SaveManager.save(current_task_index, current_task_progress)
	
func get_current_task() -> Task:
	if current_task_index >= tasks.size():
		return null
	return tasks[current_task_index]

func get_total_tasks() -> int:
	return tasks.size()

func get_completed_tasks_count() -> int:
	return current_task_index

func get_remaining_tasks_count() -> int:
	return tasks.size() - current_task_index
