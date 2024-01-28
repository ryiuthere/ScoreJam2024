extends CharacterBody2D

var MAX_SPEED := Vector2(200,300) # Maximum speed in x and y directions
var ACCELERATION := 2000 # Direction for horizontal momentum
var FRICTION := 900 # Horizontal drag when not moving
var SLOW_FORCE := 2000 # Force for slowing down to max speed if going over
var GRAVITY := 500 # Gravity
var JUMP_FORCE := 15000 # Force applied when jumping
var DASH_FORCE := Vector2(50000,25000) # Force applied when dashing in x or y direction
var HOVER_FORCE := 900 # Force applied when hovering
var HOVER_LENGTH := 0.7 # Length (in seconds) of hover time before touching groud
var DASH_COOLDOWN := 1.0 # Max cooldown between dashes

@onready var axis := Vector2.ZERO # Input Axis
@onready var dash_axis := Vector2.ZERO # Dash Axis
@onready var jump_press : bool # Was jump just pressed?
@onready var jump_hold : bool # Is jump held down?
@onready var hover : float # Hover time left before touching ground
@onready var can_hover : bool # Can player hover in current state?
@onready var dash_cooldown : float # Cooldown between dashes

const DashParticlesResource = preload("res://Assets/Scenes/DashParticles.tscn")

func _physics_process(delta) -> void:
	move(delta)

func get_input() -> void:
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	jump_press = Input.is_action_just_pressed("jump")
	jump_hold = Input.is_action_pressed("jump")
	dash_axis = Vector2.ZERO
	if (Input.is_action_just_pressed("left")):
		dash_axis.x -= 1 if $Timer.double_tap("left") else 0
	if (Input.is_action_just_pressed("right")):
		dash_axis.x += 1 if $Timer.double_tap("right") else 0
	if (Input.is_action_just_pressed("up")):
		dash_axis.y -= 1 if $Timer.double_tap("up") else 0
	if (Input.is_action_just_pressed("down")):
		dash_axis.y += 1 if $Timer.double_tap("down") else 0
	
	
func move(delta) -> void:
	get_input()
	
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta, 0)
	else:
		apply_movement(axis * ACCELERATION, delta)
	
	if (axis.x > 0):
		$AnimationPlayer.play("walk_right")
	elif (axis.x < 0):
		$AnimationPlayer.play("walk_left")
	else:
		$AnimationPlayer.pause()
	
	apply_gravity(GRAVITY, delta)
	if (!is_on_floor()):
		if (!can_hover and !jump_hold):
			hover = HOVER_LENGTH
		can_hover = can_hover || !jump_hold
	else:
		can_hover = false
	var hovering := false
	if (jump_hold):
		if (jump_press and is_on_floor()):
			hover = HOVER_LENGTH
			apply_jump(JUMP_FORCE * delta)
		elif (can_hover and hover > 0):
			hovering = true
			hover -= delta
			apply_jump(HOVER_FORCE * delta)
	if (dash_cooldown <= 0 and dash_axis != Vector2.ZERO):
		apply_dash(dash_axis * delta)
		dash_cooldown = DASH_COOLDOWN
	elif (dash_cooldown > 0):
		dash_cooldown -= delta
	$HoverParticles.emitting = hovering
	move_and_slide()

func apply_friction(amount: float, target: float) -> void:
	var test = velocity.x
	if abs(velocity.x) - abs(target) > amount:
		velocity.x += amount if velocity.x < 0 else -amount
	else:
		velocity.x = target

func apply_movement(accel: Vector2, delta: float) -> void:
	if (abs(velocity.x) <= MAX_SPEED.x or abs(velocity.x + accel.x) <= abs(velocity.x)):
		velocity += accel * delta
	if (abs(velocity.x) > MAX_SPEED.x):
		if velocity.x > 0:
			apply_friction(SLOW_FORCE * delta, MAX_SPEED.x)
		else:
			apply_friction(SLOW_FORCE * delta, -MAX_SPEED.x)

func apply_gravity(amount: float, delta: float) -> void:
	if (velocity.y < -MAX_SPEED.y):
		velocity.y += SLOW_FORCE * delta
	else:
		velocity.y += amount * delta
	
func apply_jump(amount: float) -> void:
	velocity.y -= amount

func apply_dash(dash_vector: Vector2) -> void:
	velocity = Vector2(dash_vector.x * DASH_FORCE.x, dash_vector.y * DASH_FORCE.y)
	self.add_child(DashParticlesResource.instantiate())
