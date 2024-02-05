extends CharacterBody2D

const MAX_SPEED := Vector2(200,300) # Maximum speed in x and y directions
const ACCELERATION := 2000 # Direction for horizontal momentum
const FRICTION := 1200 # Horizontal drag when not moving
const SLOW_FORCE := 2200 # Force for slowing down to max speed if going over
const GRAVITY := 620 # Gravity
const JUMP_FORCE := 17500 # Force applied when jumping
const DASH_FORCE := Vector2(60000,50000) # Force applied when dashing in x or y direction
const HOVER_FORCE := 1850 # Force applied when hovering
const HOVER_LENGTH := 60 # Length (in seconds) of hover time before touching groud
const DASH_COOLDOWN := 1.0 # Max cooldown between dashes
const DASH_COST := (1/6.8) # How much fuel dashing costs
const FUEL_CONSUMPTION_RATE := 0.075 # Rate of fuel consumption
const MIN_DASH_FUEL_REQUIRED := (2.25/8.5) # Min fuel to dash
const FASTFALL_FORCE := 1200 # Fastfall strength
const FASTFALL_THRESHOLD := 250 # Maximum downwards velocity to fastfall

@export var game_controller : Node2D

@onready var axis := Vector2.ZERO # Input Axis
@onready var dash_axis := Vector2.ZERO # Dash Axis
@onready var jump_press : bool # Was jump just pressed?
@onready var jump_hold : bool # Is jump held down?
@onready var hover : float # Hover time left before touching ground
@onready var can_hover : bool # Can player hover in current state?
@onready var dash_cooldown : float # Cooldown between dashes
@onready var fuel_amt := 1.0 # Current fuel amount
@onready var fastfall : bool # Is the player holding down?
@onready var can_boost := true # Can the player be affected by booster pads?
@onready var Hud = $Camera2D/Hud
@onready var last_dash_axis := Vector2.ZERO

const DashParticlesResource = preload("res://Assets/Scenes/DashParticles.tscn")

signal ScorePickup(amount: int)

const booster_sound := preload("res://Assets/Raw/booster.wav") as AudioStreamWAV
const dash_sound := preload("res://Assets/Raw/dash.wav") as AudioStreamWAV
const jump_sound := preload("res://Assets/Raw/jump.wav") as AudioStreamWAV
const sfx_player := preload("res://Assets/Scenes/SFXPlayer.tscn") as PackedScene

func play_jump() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(jump_sound)
	
func play_dash() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(dash_sound)
	
func play_booster() -> void:
	var sfx = sfx_player.instantiate()
	get_tree().get_root().add_child(sfx)
	sfx.play_sfx(booster_sound)

func _physics_process(delta) -> void:
	move(delta)

func get_input() -> void:
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	jump_press = Input.is_action_just_pressed("jump")
	jump_hold = Input.is_action_pressed("jump")
	fastfall = Input.is_action_pressed("down")
	dash_axis = Vector2.ZERO
	if (Input.is_action_just_pressed("dash")):
		dash_axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		dash_axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		dash_axis = dash_axis.normalized()

func move(delta) -> void:
	if (game_controller.game_state == 0):
		return
	
	get_input()
	
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta, 0)
	else:
		apply_movement(axis * ACCELERATION, delta)
	
	if (abs(velocity.x) > MAX_SPEED.x):
		$SpriteAnimator.play("dash") 
	else:
		if (axis.x > 0):
			$FacingAnimator.play("right")
		elif (axis.x < 0):
			$FacingAnimator.play("left")
		
		
		if (velocity.y < 0):
			$SpriteAnimator.play("jump")
		elif (velocity.y > 0):
			$SpriteAnimator.play("fall")
		else:
			$SpriteAnimator.play("walk")
	
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
			play_jump()
			hover = HOVER_LENGTH
			apply_jump(JUMP_FORCE * delta)
		elif (can_hover and hover > 0 and fuel_amt > 0.0):
			if (!$HoverAudio.playing):
				$HoverAudio.play()
			hovering = true
			hover -= delta
			apply_jump(HOVER_FORCE * delta)
			fuel_amt -= FUEL_CONSUMPTION_RATE * delta
	if (!hovering and $HoverAudio.playing):
		$HoverAudio.stop()
	if (dash_cooldown <= 0 and dash_axis != Vector2.ZERO and fuel_amt > MIN_DASH_FUEL_REQUIRED):
		play_dash()
		apply_dash(dash_axis * delta)
		dash_cooldown = DASH_COOLDOWN
		fuel_amt -= DASH_COST
	elif (dash_cooldown > 0):
		dash_cooldown -= delta
	if (fastfall):
		apply_fastfall(FASTFALL_FORCE * delta)
	$HoverParticles.emitting = hovering
	move_and_slide()

func apply_friction(amount: float, target: float) -> void:
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
	
func apply_fastfall(amount: float) -> void:
	if velocity.y <= FASTFALL_THRESHOLD:
		velocity.y += amount

func apply_dash(dash_vector: Vector2) -> void:
	if Hud:
		Hud.start_dash_animation()
	velocity = Vector2(dash_vector.x * DASH_FORCE.x, dash_vector.y * DASH_FORCE.y)
	self.add_child(DashParticlesResource.instantiate())
	last_dash_axis = Vector2(abs(dash_axis.x), abs(dash_axis.y))
	deform_player()

func fuel_pickup_to_hud():
	if Hud:
		Hud.start_fuelpickup_animation()

func refill_fuel(amount: float) -> void:
	fuel_amt = clamp(fuel_amt + amount, 0, 1)
	fuel_pickup_to_hud()

func score_pickup() -> void:
	ScorePickup.emit(500)
	
func boost_up(amount: int) -> void:
	if can_boost:
		play_booster()
		velocity.y = -amount
		can_boost = false
		$BoostCooldown.start()

func _on_boost_cooldown_timeout() -> void:
	can_boost = true
	
func deform_player() -> void:
	"""In future games where we'll use a state machine for the player, it would be fairly simple to have
	these parameters be functions of acceleration. That way, dashing, boosting, or colliding with something
	at a high speed would cause a proportionate squish effect, and we don't have to worry about making 
	this feel consistent since it'll be done automatically."""
	var deform_tween = get_tree().create_tween()
	var is_diagonal = abs(last_dash_axis.x - last_dash_axis.y) <= 0.01
	if is_diagonal:
		last_dash_axis.y = 0.0
		last_dash_axis.x = 0.5
	else:
		last_dash_axis.y *= 1.15
	%Sprite2D.material.set_shader_parameter("scale_squish", is_diagonal)
	deform_tween.tween_method(set_deform, 0.5, 0.0, 0.15) 

func set_deform(def_scale: float) -> void:
	def_scale = mapped_to_deform_curve(def_scale)
	%Sprite2D.material.set_shader_parameter("deform_x", last_dash_axis.x * def_scale)
	%Sprite2D.material.set_shader_parameter("deform_y", last_dash_axis.y * def_scale)

func mapped_to_deform_curve(value: float):
	return value
