extends Sprite2D

var yPos = 0.0


func _physics_process(_delta) -> void:
	
	# (sin(time * hover speed) * hover range) - offset
	yPos = (sin(Time.get_ticks_msec() * 0.005) * 2) - 2
	%Sprite2D.position = Vector2(0,yPos)
