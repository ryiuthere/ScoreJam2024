extends AudioStreamPlayer


func _on_bgm_audio_finished():
	play()


func _on_finished():
	$FullLoop.play()
