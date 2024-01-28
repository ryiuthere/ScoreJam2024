extends Node

var target_goal := "right"
var score := 0
var reset_time := 300
var time := 300

@export var delivery_score := 2500
@export var coin_pickup_score := 100
@export var timer : Timer
	
@onready var game_state := 0 # 0 = Pre-game (paused), 1 = game in progress
@onready var player_initial_position = $Player.global_position

func _ready() -> void:
	timer = $GameTimer
	$ScreenCover.visible = true
	$TileMap.calc_tileset_count()
	$TileMap.randomize_tileset()
	time = reset_time

func _input(event) -> void:
	if (game_state == 0):
		if (Input.is_anything_pressed()):
			game_state = 1
			$ScreenCover.visible = false
			timer.start()
	else:
		if (Input.is_action_just_pressed("reset")):
			score = 0
			game_state = 0
			$ScreenCover.visible = true
			$Player.global_position = player_initial_position
			$TileMap.randomize_tileset()
			time = reset_time
			timer.stop()

func touch_goal(goal: String):
	if target_goal == goal:
		target_goal = "right" if goal == "left" else "left"
		score += delivery_score
		$TileMap.randomize_tileset() # This causes a lagspike, is it possible to run this concurrently during gameplay?
		$Player.refill_fuel(1/3.4)

func _on_goal_1_body_entered(_body):
	touch_goal("left")

func _on_goal_2_body_entered(_body):
	touch_goal("right")

func _on_game_timer_timeout(): # Called every second
	time -= 1
	if time <= 0:
		print("debug game over") # TODO: remove

func _on_player_score_pickup(amount):
	score += amount
	print("Score: " + str(score))
