extends Node

var target_goal := "right"
var score := 0
var time := 300

@export var delivery_score := 2500
@export var coin_pickup_score := 100

@export var timer : Timer

func _ready():
	timer = $GameTimer

func touch_goal(goal: String):
	if target_goal == goal:
		target_goal = "right" if goal == "left" else "left"
		score += delivery_score
		$TileMap.randomize_tileset() # This causes a lagspike, is it possible to run this concurrently during gameplay?
		$Player.refill_fuel(1/3.4)

func _on_goal_1_body_entered(body):
	touch_goal("left")

func _on_goal_2_body_entered(body):
	touch_goal("right")

func _on_coin_pickup_body_entered(body): # Connect this to a coin emitter 
	score += coin_pickup_score

func _on_game_timer_timeout(): # Called every second
	time -= 1
	if time <= 0:
		print("debug game over") # TODO: remove
