extends Node

var text = FileAccess.get_file_as_string("res://config/machines.json")
var parsed_data = JSON.parse_string(text)
