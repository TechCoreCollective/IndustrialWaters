extends Area2D

@export var speed = 150.0

func _process(delta):
	# Nepřítel pluje doleva směrem k ponorce
	position.x -= speed * delta

func _on_area_entered(area):
	if area.name == "Torpedo": # Pokud nás zasáhne torpédo
		area.queue_free() # Smaže torpédo
		queue_free()      # Smaže nepřítele
