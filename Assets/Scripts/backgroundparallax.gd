extends ParallaxBackground

var rng = RandomNumberGenerator.new()
var angle : float
var speed : float
var velocity_vector : Vector2

func _ready() -> void:
	angle = rng.randf_range(0, 2*PI)
	speed = rng.randf_range(20.0, 40.0)
	velocity_vector = Vector2(cos(angle), sin(angle)) * speed
	request_ready()
	

func _process(delta) -> void:
	offset += velocity_vector * delta
	if abs(offset.x) >= 2160:
		print('x')
		offset.x = 0.0
	if abs(offset.y) >= 2160:
		print('y')
		offset.y = 0.0
