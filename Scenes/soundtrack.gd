extends Node2D  

@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	unmute_audio()

func _on_mutebutton_pressed():
	
	
	if audio_player.playing:
		mute_audio()
	else:
		unmute_audio()

func mute_audio():
	audio_player.stop()
	$AudioStreamPlayer/Mutebutton.text = "Sound: OFF"

func unmute_audio():
	audio_player.play()
	$AudioStreamPlayer/Mutebutton.text = "Sound: ON"
