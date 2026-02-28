extends Node2D

# Tímto řekneme Godotu, kterou scénu má používat jako "šablonu"
@export var enemy_scene: PackedScene 

func _on_timer_timeout():
	# 1. Vytvoření instance (kopie) nepřítele ze šablony

	var enemy = enemy_scene.instantiate()
	
	# 2. Určení pozice, kde se objeví
	# Chceme, aby byl kousek za pravým okrajem obrazovky
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y
	
	# X bude šířka obrazovky + kousek (např. 100 pixelů), aby se neobjevil skokově
	var spawn_x = screen_width + 100
	
	# Y bude náhodné číslo od horního okraje (50) po spodní (height - 50)
	var spawn_y = randf_range(50, screen_height - 50)
	
	enemy.position = Vector2(spawn_x, spawn_y)
	
	# 3. Přidání nepřítele do scény (aby byl vidět a existoval)
	add_child(enemy)


@warning_ignore("unused_parameter")


func _on_killzone_area_entered(area):
	# Zkontrolujeme, jestli do zóny vletěl nepřítel
	# (Předpokládám, že nepřátelé jsou ve skupině "enemies")
	if area.is_in_group("enemies"):
		game_over()

func game_over():
	# 1. Zastavíme čas hry (všechno zamrzne)
	get_tree().paused = true
	
	# 2. Zobrazíme Game Over screen
	$CanvasLayer/GameOverScreen.visible = true

# Tip: Přidej možnost restartu pomocí klávesy R
func _process(_delta):
	if $CanvasLayer/GameOverScreen.visible and Input.is_action_just_pressed("ui_accept"): # Mezerník nebo Enter
		get_tree().paused = false
		get_tree().reload_current_scene()
