extends Node

func _physics_process(delta) -> void:
	$Sprite2D.position = Vector2(0,(sin(Time.get_ticks_msec() * delta / 2.5) * 1.3) - 3)

func _on_body_entered(body):
	if (body.has_method("score_pickup")):
		body.score_pickup()
		queue_free()
