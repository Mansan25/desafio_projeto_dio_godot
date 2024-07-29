class_name Player
extends CharacterBody2D

@export_category ("Movimento")
@export var speed: float = 3

@export_category ("Espada")
@export var sword_damage: int = 2

@export_category ("Magic Power")
@export var magic_power_damage: int = 1
@export var magic_power_interval: float = 30
@export var magic_power_scene: PackedScene

@export_category ("Vida")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefeb: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $Sword_area
@onready var hitbox_area: Area2D = $Hitbox_Area
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var was_running: bool = false
var is_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var magic_power_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready():
	GameMananger.player = self

# Funções principais
func _process(delta: float) -> void:
	GameMananger.player_position = position
	
	# Ler input
	read_input()
	
	# Processar ataque
	update_attack_cooldown(delta)
	
		# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()

	# Processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
		
	# Processar dano
	update_hitbox_detection(delta)

	# Power Magic
	update_magic_power(delta)
	
	# Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta: float) -> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

# Funções de organização
func read_input() -> void:
	# Obter Input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar deadzone do input vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0	
	if abs(input_vector.y) < deadzone:
			input_vector.y = 0.0

# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation() -> void:
	# Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func update_attack_cooldown(delta: float) -> void:
	# Atualizar temporizador de ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running =false
			animation_player.play("idle")

func update_magic_power(delta: float) -> void:
	# Atualizar temporizador
	magic_power_cooldown -= delta
	if magic_power_cooldown > 0: return
	magic_power_cooldown = magic_power_interval
	
	# Criar Magic
	var magic_power = magic_power_scene.instantiate()
	magic_power.damage_amount = magic_power_damage
	add_child(magic_power)
	
	
func attack() -> void:
	
	if is_attacking:
		return
		
	animation_player.play("attack_side_1")
	# Configurar animation_player
	attack_cooldown = 0.6
	
	# Marcar ataque
	is_attacking = true

# Aplicar dano nos inimigos
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frequência
	hitbox_cooldown = 0.5
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
				

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("O herói recebeu ", amount, " de dano.", " A vida total é de ", health, " / ", max_health)

# Piscar enemy
	modulate = Color.INDIAN_RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

# Processar morte
	if health <= 0:
		die()
		
func die() -> void:
	GameMananger.end_game()
		
	if death_prefeb:
		var death_object = death_prefeb.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	print("Fim da jornada, heroi")
	queue_free()
	
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("O herói recebeu ", amount, " de cura.", " A vida total é de ", health, " / ", max_health)
	return health
	

 
