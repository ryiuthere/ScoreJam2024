extends Node

@export var game_controller: Node2D

func set_score(score: int) -> void:
	if (score <= game_controller.high_score):
		$Label.text = "Score: %s\n\nHigh Score: %s\n\n[Click] to try again." % [str(score), str(game_controller.high_score)]
	else:
		$Label.text = "Score: %s *New High Score!*\n\nHigh Score: %s\n\n[Click] to try again." % [str(score), str(game_controller.high_score)]
