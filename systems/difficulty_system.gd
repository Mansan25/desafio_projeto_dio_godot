extends Node

@export var mob_spawner: mobspawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_per_minute: float = 30.0
@export var wave_duration: float = 20.0
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameMananger.is_game_over: return
	
	# Incrementar temporizador
	time += delta
	
	# Dificuldade linear (Linha verde)
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60.0)
	
	# Sistema de ondas (Linha rosa)
	var sin_wave = sin((time * TAU) / wave_duration)
	# PI = Pi || TAU = 2Pi
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
		# Aplicar dificuldade
	mob_spawner.mobs_per_minute = spawn_rate
