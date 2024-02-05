extends Node

var target_goal := "right"
var high_score := 0
var score := 0
var reset_time := 150
var time := 150

signal return_to_main

@export var delivery_score := 7500
@export var coin_pickup_score := 100
@export var timer : Timer
	
@onready var game_state := 0 # 0 = Pre-game (paused), 1 = game in progress
@onready var player_initial_position = $Player.global_position

const goal_sound := preload("res://Assets/Raw/goal.wav") as AudioStreamWAV
const sfx_player := preload("res://Assets/Scenes/SFXPlayer.tscn") as PackedScene

func play_goal_sound() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(goal_sound)

func _ready() -> void:
	timer = $GameTimer
	$TileMap.calc_tileset_count()
	reset(false)

func _input(event) -> void:
	if (game_state == 0):
		if ($EndScreen.visible == false and Input.is_action_just_pressed("jump")):
			game_state = 1
			$ScreenCover.visible = false
			$EndScreen.visible = false
			timer.start()
		elif (event.is_action_pressed("click")):
			$EndScreen.visible = false
	else:
		if (event.is_action_pressed("reset")):
			reset(false)
	if event.is_action_pressed("escape"):
		return_to_main.emit()

func touch_goal(goal: String):
	if target_goal == goal:
		play_goal_sound()
		target_goal = "right" if goal == "left" else "left"
		score += delivery_score
		$TileMap.randomize_tileset() # This causes a lagspike, is it possible to run this concurrently during gameplay?
		$Player.refill_fuel(1.0)

func _on_goal_1_body_entered(_body):
	touch_goal("left")

func _on_goal_2_body_entered(_body):
	touch_goal("right")

func _on_game_timer_timeout(): # Called every second
	time -= 1
	if (time == 0):
		$EndScreen.set_score(score)
		reset(true)

func _on_player_score_pickup(amount):
	score += amount

func reset(show_end_screen: bool) -> void:
	high_score = score if score > high_score else high_score
	target_goal = "right"
	score = 0
	game_state = 0
	$ScreenCover.visible = true
	$EndScreen.visible = show_end_screen
	$Player.global_position = player_initial_position
	$Player.velocity = Vector2.ZERO
	$Player.refill_fuel(1)
	$TileMap.randomize_tileset()
	time = reset_time
	timer.stop()
