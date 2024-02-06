extends ParallaxBackground

var rng = RandomNumberGenerator.new()
var angle : float
var speed : float
var velocity_vector : Vector2

func _ready() -> void:
	angle = rng.randf_range(0, 2 * PI)
	speed = rng.randf_range(30.0, 45.0)
	velocity_vector = Vector2(cos(angle), sin(angle)) * speed
	request_ready()
	
func _process(delta) -> void:
	offset += velocity_vector * delta
	var r = 1080*2
	if offset.x >= r:
		offset.x -= r
	elif offset.x <= -r:
		offset.x += r
		
	if offset.y >= r:
		offset.y -= r
	elif offset.y <= -r:
		offset.y += r
