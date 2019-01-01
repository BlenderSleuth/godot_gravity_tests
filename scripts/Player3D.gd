extends KinematicBody

export (int) var gravity = 1200

export (int) var run_speed = 100
export (int) var fly_speed = 20
export (int) var max_run_speed = 500
export (float) var run_damp = 0.85
export (float) var fly_damp = 0.98

export (int) var jump_speed = 100
export (float) var jump_time = 0.24 # Time in seconds for advanced control over jump

# Planet on which the player is being attracted
onready var current_planet = get_node("../Planet")

onready var ground_ray = $GroundRay

# Velocity is relative to node, unrotated
var velocity = Vector3()
var jumping = false

func _ready():
	pass

var timer = 0.0
func jump(delta):
	var newjump = Input.is_action_just_pressed('ui_select')
	
	# Only reset if it is a new jump, and from the floor
	if newjump and not jumping and is_on_floor():
		jumping = true
		velocity.y = 0
		timer = 0.0
	
	# More of the current jump
	if jumping and timer < jump_time:
		var proportion_completed = timer / jump_time
		var jump_vec = Vector2(0, -jump_speed).linear_interpolate(Vector2(0, 0), proportion_completed)
		velocity += jump_vec
		timer += delta
	else:
		# Finished jumping
		jumping = false

func get_input(delta):
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_pressed('ui_select')

	# Slow down velocity 
	velocity.x *= run_damp if is_on_floor() else fly_damp

	if jump:
		jump(delta)
	else:
		jumping = false
	
	# Different speed on ground and in air
	var move_speed = run_speed if is_on_floor() else fly_speed
	if right:
		velocity.x += move_speed
	if left:
		velocity.x -= move_speed
	
	# Make sure player doesn't accelerate too much
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)

func _physics_process(delta):
	# Player movement and jumps
	get_input(delta)
	
	var gravVec = Vector2()
	if ground_ray.is_colliding() and current_planet:
		gravVec = -ground_ray.get_collision_normal()
	else:
		# Normalised vector in direction of gravity
		gravVec = (current_planet.global_position - global_position).normalized() if current_planet else Vector2(0, 1)
		print("halp")
		
	# Rotation to point towards the gravitational force
	var rotation_angle = Vector2(0, 1).angle_to(gravVec)
	# Rotate the kinematic body so the bottom faces the force
	rotation = rotation_angle
	
	# Velocity in global coordinates
	var global_velocity = velocity.rotated(rotation)
	
	# Apply gravity
	global_velocity += gravVec.normalized() * gravity * delta
	
	# Floor is relative to player orientation
	var floor_normal = Vector2(0, -1).rotated(rotation)
	# Move player based on velocity
	global_velocity = move_and_slide(global_velocity, floor_normal)
	# Local velocity
	velocity = global_velocity.rotated(-rotation)
	
	# If player collided with something
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		jumping = false
