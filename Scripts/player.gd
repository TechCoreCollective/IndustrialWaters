extends CharacterBody2D

@export var speed = 300.0
@export var torpedo_scene: PackedScene # Sem v inspektoru přetáhneš scénu torpéda

func _physics_process(_delta):
	# Pohyb nahoru a dolů
	var direction = Input.get_axis("ui_up", "ui_down")
	velocity.y = direction * speed
	move_and_slide()
	
	# Střelba
	if Input.is_action_just_pressed("ui_accept"): # Mezerník (Space)
		shoot()

func shoot():
	var t = torpedo_scene.instantiate()
	owner.add_child(t) # Přidá torpédo do hlavní scény
	t.global_position = $Muzzle.global_position # Nastaví pozici na konec hlavně


	print("!!!")
