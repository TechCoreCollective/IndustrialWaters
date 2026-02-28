extends Node

const SAVE_PATH := "user://save.json"

var current_task_index: int = 0


func _ready() -> void:
	_load()




func save(task_index: int) -> void:
	current_task_index = task_index
	
	var save_data := {
		"current_task_index": current_task_index
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Write failed")
		return
	
	file.store_string(JSON.stringify(save_data))
	file.flush()
	file.close()


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Read failed")
		return
		
	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	file.close()
	
	if result != OK:
		push_error("SaveManager: Corrupt save — resetting")
		delete_save()
		return
		
	current_task_index = int(json.data.get("current_task_index", 0))


func delete_save() -> void:
	current_task_index = 0
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
