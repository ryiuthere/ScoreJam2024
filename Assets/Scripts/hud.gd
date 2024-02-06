extends Control

var fuelbar : Sprite2D
var timetext : Label
var scoretext : Label
var highscoretext : Label
var boosttweentimer : Timer
var fptweentimer : Timer

@export var player_node : CharacterBody2D
@export var game_controller : Node2D

@onready var boosting := false
@onready var glowing := false

func _ready():
	fuelbar = %Fuelbar
	timetext = $TimeText
	scoretext = $ScoreText
	highscoretext = $HighScoreText
	boosttweentimer = %BoostTweenTimer
	fptweentimer = %FuelpickupTweenTimer
	set_fuel(1.0)
	
func _process(_delta):
	set_fuel(player_node.fuel_amt)
	update_labels()

func set_fuel(amt):
	var adjusted_amt : float
	var opacity := 0.25
	
	if boosting:
		var timeleft = boosttweentimer.time_left/boosttweentimer.wait_time
		adjusted_amt = tweak_fuel_amt_displayed(timeleft, amt)
		opacity += mult_opacity(timeleft, 0.2)
	else:
		adjusted_amt = amt
	
	if glowing:
		var timeleft = fptweentimer.time_left/fptweentimer.wait_time
		opacity += mult_opacity(timeleft, 0.2)
		
	fuelbar.material.set_shader_parameter("fuel_amt", adjusted_amt)
	
	opacity += adjusted_amt * 0.3
	fuelbar.material.set_shader_parameter("opacity", opacity)

func update_labels():
	timetext.text = parsed_time(game_controller.time)
	scoretext.text = str(game_controller.score)
	highscoretext.text = "Highscore:" + str(game_controller.high_score)

func parsed_time(seconds):
	return "%d:%02d" % [seconds / 60, seconds % 60]

func tweak_fuel_amt_displayed(timeleft, amt) -> float:
	"""Visually adds some extra fuel on a curve after boosting for a smoothing effect"""
	
	return amt + ((timeleft) ** 8) * player_node.DASH_COST 

func mult_opacity(timeleft, strength) -> float:
	return ((timeleft) ** 1.2) * strength
	
func start_dash_animation() -> void:
	boosttweentimer.start()
	boosting = true

func start_fuelpickup_animation() -> void:
	fptweentimer.start()
	glowing = true

func _on_boost_tween_timer_timeout():
	boosting = false

func _on_fuelpickup_tween_timer_timeout():
	glowing = false
