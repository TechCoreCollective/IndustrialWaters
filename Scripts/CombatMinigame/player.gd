extends CharacterBody2D

@export var speed = 300.0
@export var torpedo_scene: PackedScene

# Odkaz na náš nový Timer
@onready var shoot_timer = $"COOLDOWN PIČO"

func _physics_process(_delta):
	var direction = Input.get_axis("ui_up", "ui_down")
	velocity.y = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		# Tady je ta změna: střílej jen když Timer NEBĚŽÍ
		if shoot_timer.is_stopped():
			shoot()

func shoot():
	var t = torpedo_scene.instantiate()
	owner.add_child(t)
	t.global_position = $Muzzle.global_position
	
	# Spustíme Timer - dokud běží, podmínka nahoře bude false
	shoot_timer.start()
	print("!!!")
