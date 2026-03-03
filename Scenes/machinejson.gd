extends Node

var text = UID.JSON_MACHINES.file_contents
var parsed_data

func _ready():
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		parsed_data = json.get_data()
		return
	print("JSON Error: ", json.get_error_message())
	print("Line: ", json.get_error_line())
