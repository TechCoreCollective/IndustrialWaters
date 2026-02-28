extends Control

@onready var label_requirement: Label = $VBoxContainer/LabelRequirement
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label_description: Label = $VBoxContainer/LabelDescription
@onready var label_name: Label = $VBoxContainer/LabelName
@onready var label_progress: Label = $VBoxContainer/LabelProgress
@onready var check_button: CheckButton = $VBoxContainer/CheckButton
@onready var panel: Panel = $Panel
@onready var v_box_container: VBoxContainer = $VBoxContainer

var current_async_task = TaskManager.get_completed_tasks_count()


func _process(_delta):
	_sync_panel()
	update_ui()
	
	if current_async_task != TaskManager.get_completed_tasks_count():
		check_button.set_pressed_no_signal(false)
		current_async_task = TaskManager.get_completed_tasks_count()
	
	if check_button.button_pressed:
		print("button pressed")
		print(TaskManager.get_current_task().required_item_id)
		if Utils.remove_resources_safe([{"id": TaskManager.get_current_task().required_item_id, "amount": 1}]):
			print("resource going")
			TaskManager.current_task_progress += 1
	
	if TaskManager.current_task_progress >= TaskManager.get_current_task().required_amount:
		TaskManager.complete_current_task()
		
		
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
	
func _sync_panel():
	panel.position = v_box_container.position
	panel.scale = v_box_container.scale
