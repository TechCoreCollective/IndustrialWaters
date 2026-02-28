extends Control

@onready var target: Panel = $Panel
@onready var source: VBoxContainer = $VBoxContainer

func _ready():
	source.resized.connect(_sync_size)
	_sync_size()

func _sync_size():
	target.size = source.size
	target.position = source.position
