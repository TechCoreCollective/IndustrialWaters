extends Area2D

@export var speed = 150.0

func _process(delta):
	# Nepřítel pluje doleva směrem k ponorce
	position.x -= speed * delta

func _on_area_entered(area):
	# Kontrolujeme skupinu, ne jméno
	if area.is_in_group("projectiles"):
		area.queue_free() # Smaže torpédo
		queue_free()      # Smaže nepřítele
