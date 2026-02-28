extends Control

@onready var label_requirement: Label = $VBoxContainer/LabelRequirement
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label_description: Label = $VBoxContainer/LabelDescription
@onready var label_name: Label = $VBoxContainer/LabelName
@onready var label_progress: Label = $VBoxContainer/LabelProgress

func _process(_delta):
	update_ui()

func update_ui():
	var manager = TaskManager
	var task = manager.get_current_task()
	
	label_progress.text = "Completed: %d / %d" % [
		manager.current_task_index,
		manager.tasks.size()
	]
	
	if task == null:
		label_name.text = "All tasks completed"
		label_description.text = ""
		label_requirement.text = ""
		progress_bar.value = 100
		return
	
	label_name.text = task.name
	label_description.text = task.description
	
	label_requirement.text = "%d / %d" % [
		manager.current_task_progress,
		task.required_amount
	]
	
	label_progress.text = "%d / %d" % [
		TaskManager.get_completed_tasks_count(),
		TaskManager.get_total_tasks()
	]
	progress_bar.value = TaskManager.current_task_progress
	progress_bar.max_value = TaskManager.get_current_task().required_amount
