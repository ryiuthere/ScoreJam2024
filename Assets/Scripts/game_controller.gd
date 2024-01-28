extends Node

var target_goal := "right"
var score = 0

func touch_goal(goal: String):
	if target_goal == goal:
		target_goal = "right" if goal == "left" else "left"
		score += 1
		$TileMap.randomize_tileset()

func _on_goal_1_body_entered(body):
	touch_goal("left")

func _on_goal_2_body_entered(body):
	touch_goal("right")
