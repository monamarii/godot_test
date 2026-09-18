extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 900.0
const DASH_DURATION = 0.15
const DOUBLE_TAP_WINDOW = 0.25

var max_jumps = 2
var jumps_left = max_jumps

var is_dashing = false
var dash_timer = 0.0
var dash_direction = 0

var last_left_press_time = -10.0
var last_right_press_time = -10.0
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	#gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps_left = max_jumps
		
	#jump
	if Input.is_action_just_pressed("jump_space") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY * 0.9
		jumps_left -= 1
		
	# --- Dash detection ---
	var time_now = Time.get_ticks_msec() / 1000.0

	if Input.is_action_just_pressed("left_a"):
		if Input.is_action_pressed("dash_left") or (time_now - last_left_press_time) < DOUBLE_TAP_WINDOW:
			start_dash(-1)
		last_left_press_time = time_now

	if Input.is_action_just_pressed("right_d"):
		if Input.is_action_pressed("dash_right") or (time_now - last_right_press_time) < DOUBLE_TAP_WINDOW:
			start_dash(1)
		last_right_press_time = time_now

	# --- Dash execution ---
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

		# Reuse walk animations during dash
		if dash_direction > 0:
			if anim.animation != "right":
				anim.play("right")
		else:
			if anim.animation != "left":
				anim.play("left")
	else:
		var direction := Input.get_axis("left_a", "right_d")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# --- Animation handling (normal movement) ---
		if direction > 0:
			if anim.animation != "right":
				anim.play("right")
		elif direction < 0:
			if anim.animation != "left":
				anim.play("left")
		else:
			if anim.animation != "idle":
				anim.play("idle")
	move_and_slide()
	
func start_dash(direction: int) -> void:
	is_dashing = true
	dash_direction = direction
	dash_timer = DASH_DURATION
