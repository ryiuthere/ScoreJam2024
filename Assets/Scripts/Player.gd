extends CharacterBody2D

var MAX_SPEED = 200
var ACCELERATION = 2000
var FRICTION = 1500
var GRAVITY = 500
var JUMP_FORCE = 15000

@onready var axis := Vector2.ZERO
@onready var jump := false

func _physics_process(delta) -> void:
	move(delta)

func get_input():
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	jump = Input.is_action_just_pressed("jump")
	
func move(delta):
	get_input()
	
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	
	if (velocity.x > 0):
		$AnimationPlayer.play("walk_right")
	elif (velocity.x < 0):
		$AnimationPlayer.play("walk_left")
	else:
		$AnimationPlayer.pause()
	
	apply_gravity(GRAVITY * delta)
	if (is_on_floor() and jump):
		apply_jump(JUMP_FORCE * delta)
	move_and_slide()

func apply_friction(amount):
	if abs(velocity.x) > amount:
		velocity.x += amount if velocity.x < 0 else -amount
	else:
		velocity.x = 0

func apply_movement(accel):
	velocity += accel
	velocity.x = MAX_SPEED if velocity.x > MAX_SPEED else -MAX_SPEED if velocity.x < -MAX_SPEED else velocity.x

func apply_gravity(amount):
	velocity.y += amount
	
func apply_jump(amount):
	velocity.y -= amount
