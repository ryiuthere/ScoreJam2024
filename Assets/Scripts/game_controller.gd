extends Node

var target_goal := "right"
@export var score := 0
@export var score_increment := 1000

func touch_goal(goal: String):
	if target_goal == goal:
		target_goal = "right" if goal == "left" else "left"
		score += score_increment
		$TileMap.randomize_tileset()

func _on_goal_1_body_entered(body):
	touch_goal("left")

func _on_goal_2_body_entered(body):
	touch_goal("right")
