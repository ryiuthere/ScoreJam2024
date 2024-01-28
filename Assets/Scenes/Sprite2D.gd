extends Sprite2D

var yPos = 0.0


func _physics_process(delta) -> void:
	
	# (sin(time * hover speed) * hover range) - offset
	yPos = (sin(Time.get_ticks_msec() * 0.005) * 1) - 2
	print(yPos)
	%Sprite2D.position = Vector2(0,yPos)
