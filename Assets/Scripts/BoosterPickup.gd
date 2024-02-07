extends Area2D

func _on_body_entered(body):
	if (body.has_method("boost_up")):
		body.boost_up(1000, rotation)
