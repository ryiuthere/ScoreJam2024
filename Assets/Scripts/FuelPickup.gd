extends Node


func _on_body_entered(body):
	if (body.has_method("refill_fuel")):
		body.refill_fuel(0.5)
		queue_free()
