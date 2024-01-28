extends Control

var fuelbar : Sprite2D
var timetext : Label
var scoretext : Label

@export var player_node : CharacterBody2D
@export var game_controller : Node2D

func _ready():
	fuelbar = %Fuelbar
	timetext = $TimeText
	scoretext = $ScoreText
	set_fuel(1.0)
	
func _process(_delta):
	set_fuel(player_node.fuel_amt)
	update_labels()

func set_fuel(amt):
	fuelbar.material.set_shader_parameter("fuel_amt", amt)

func update_labels():
	timetext.text = parsed_time(game_controller.time)
	scoretext.text = str(game_controller.score)

func parsed_time(seconds):
	return "%d:%02d" % [seconds / 60, seconds % 60]
