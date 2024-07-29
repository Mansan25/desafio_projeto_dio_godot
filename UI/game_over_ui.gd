class_name GameOverUI
extends CanvasLayer


@onready var time_label: Label = %Time
@onready var monsters_label: Label = %Monsters


@export var restart_delay: float = 5.0
var restart_cooldown: float


func _ready():
	time_label.text = GameMananger.time_elapsed_string
	monsters_label.text = str(GameMananger.monsters_defeated_counter)
	restart_cooldown = restart_delay


func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()


func restart_game():
	GameMananger.reset()
	get_tree().reload_current_scene()
