extends Sprite2D

@onready var goal_position = %Goal2.position
@onready var player = get_parent()
@onready var time_since_last := 0
@onready var started := false
const color := Color(0.902, 0.306, 0.651, 0.71)

func _ready():
	modulate = Color(0.902, 0.306, 0.651, 0.0)
	
func _process(_delta):
	if player and goal_position:
		rotation = calc_angle(player.position, goal_position)
	
	if time_since_last >= 2.0:
		visible = true
	
	if not started and time_since_last >= 15:
		started = true
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self, "scale", Vector2(0.11, 0.11), 0.3)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.8), 0.3)
		tween.tween_property(self, "modulate", color, 0.75)
		tween2.tween_property(self, "scale", Vector2(0.09, 0.09), 0.75)
		tween.tween_callback(hide_if_completed)
	
func calc_angle(v1: Vector2, v2: Vector2) -> float:
	var a = atan2(v2.y-v1.y, v2.x-v1.x)
	if a < 0:
		a += PI * 2
	return a

func _on_game_timer_timeout():
	time_since_last += 1

func make_delivery():
	started = false
	time_since_last = 0
	visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	
func hide_if_completed():
	if not started:
		modulate = Color(1.0, 1.0, 1.0, 0.0)
		
func reset_goal_position():
	started = false
	time_since_last = 0
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	goal_position = %Goal2.position
		
	
