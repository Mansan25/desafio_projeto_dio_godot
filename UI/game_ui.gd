extends CanvasLayer

@onready var timer: Label = %Timer
@onready var meat: Label = %Meat

var time_elapsed: float = 0.0
var meat_counter: int = 0

func _ready():
	GameMananger.player.meat_collected.connect(on_meat_collected)
	meat.text = str(meat_counter)

func _process(delta: float):
# Update Timer
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	timer.text = "%02d:%02d" % [minutes, seconds]

func on_meat_collected(regeneration_value:int) -> void:
	meat_counter += 1
	meat.text = str(meat_counter)
