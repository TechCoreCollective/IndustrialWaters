extends Node2D  # Nebo Node, podle toho co je hlavní uzel

# Pomocí $ získáme přístup k přehrávači hudby
@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	unmute_audio()

func _on_mutebutton_pressed():
	# Tato funkce se spustí, když klikneš na tlačítko
	# (Předpokládám, že jsi signál 'pressed' připojil sem do skriptu)
	
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
