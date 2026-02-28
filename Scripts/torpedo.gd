extends Area2D

@export var speed = 400.0

func _process(delta):
	# Torpédo letí rovně doprava
	position.x += speed * delta

# Pokud torpédo vyletí z obrazovky, smažeme ho (šetří paměť)
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
