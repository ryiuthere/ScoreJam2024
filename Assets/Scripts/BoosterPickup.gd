extends Area2D

func _on_body_entered(body):
	if (body.has_method("boost_up")):
		if rotation == 180:
			body.boost_up(750, rotation)
		else:
			body.boost_up(1000, rotation)
	
