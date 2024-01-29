extends Node

const pickup_sound := preload("res://Assets/Raw/pickupCoin.wav") as AudioStreamWAV
const sfx_player := preload("res://Assets/Scenes/SFXPlayer.tscn") as PackedScene

func play_sound() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(pickup_sound)

func _physics_process(delta) -> void:
	$Sprite2D.position = Vector2(0,(sin(Time.get_ticks_msec() * delta / 2.5) * 1.3) - 3)

func _on_body_entered(body):
	if (body.has_method("score_pickup")):
		body.score_pickup()
		queue_free()
		play_sound()
