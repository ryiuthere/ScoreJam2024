extends AudioStreamPlayer

func play_sfx(resource):
	stream = resource
	$Timer.wait_time = stream.get_length()
	play()
	$Timer.start()


func _on_timer_timeout():
	queue_free()
