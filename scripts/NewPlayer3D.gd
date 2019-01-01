extends KinematicBody

# Tweakable properties

export (float) var gravity = 4

export (float) var run_speed = 8
export (float) var fly_speed = 2
export (float) var max_run_speed = 15

export (float) var run_damp = 0.85
export (float) var fly_damp = 0.98

export (int) var jump_speed = 20
export (float) var jump_time = 0.2 # Time in seconds for advanced control over jump

var planet_position = Vector3()

# Node References
onready var player_camera = $PlayerCamera
onready var front_camera = $"../FrontCamera"


# Velocity in global coordinates
var velocity = Vector3()


func _ready():
	pass


var using_front_camera = false
func _process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		using_front_camera = !using_front_camera
		if using_front_camera:
			front_camera.make_current()
		else:
			player_camera.make_current()


var jumping = false
var timer = 0.0
func jump(delta):
	var newjump = Input.is_action_just_pressed('ui_select')
	
	# Only reset if it is a new jump, and from the floor
	if newjump and not jumping and is_on_floor():
		jumping = true
		timer = 0.0
	
	# More of the current jump
	if jumping and timer < jump_time:
		var proportion_completed = timer / jump_time
		# Gradually decrease the jump speed over the time of the jump
		var jump_amount = lerp(jump_speed, 0, proportion_completed)
		timer += delta
		return jump_amount
	else:
		# Finished jumping
		jumping = false
	
	return 0


func get_movement(delta):
	# Input events
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var forward = Input.is_action_pressed("ui_up")
	var backward = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_pressed('ui_select')

	# Movement velocity in local coordinates
	var move = Vector3()
	
	# Different speed on ground and in air
	var move_speed = run_speed if is_on_floor() else fly_speed
	if right:
		move.x += move_speed
	if left:
		move.x -= move_speed
	if backward:
		move.z += move_speed
	if forward:
		move.z -= move_speed
	
	# Make sure player doesn't accelerate too much, clamp vector length
	move = move.normalized() * clamp(move.length(), -move_speed, move_speed)
	
	# Apply jump
	if jump:
		move.y += jump(delta)
	else:
		jumping = false
	
	return move


func _physics_process(delta):
	# Vector in the direction of gravity
	var grav_vec = (planet_position - transform.origin).normalized()
	
	# Feet of player
	var down = -transform.basis.y
	
	# Rotation axis, perpindicular to the down direction and gravity direction
	var rot_axis = down.cross(grav_vec)
	
	# Check to make sure we don't screw up later on, can't normalize null vector
	if (rot_axis.length_squared() == 0):
		var front = transform.basis.z
		rot_axis = front
	else:
		rot_axis = rot_axis.normalized()
	
	# Find the angle to rotate
	var dot = clamp(down.dot(grav_vec), -1, 1)
	# Both are unit vectors, so dot product = cos(angle)
	var angle = acos(dot)
	
	# Rotate player so the local down direction is in the direction of gravity
	transform.basis = transform.basis.rotated(rot_axis, angle)
	transform = transform.orthonormalized() # Fix up basis
	
	# Apply input movement
	var movement = get_movement(delta)
	# Movement is a local translation, so transform with the rotation to get it in global coordinates
	velocity += transform.basis.xform(movement)
	
	# Add gravity 
	velocity += grav_vec * gravity
	
	# Apply friction or air resistance
	var damp = run_damp if is_on_floor() else fly_damp
	
	# Move player
	velocity = move_and_slide(velocity, -grav_vec) * damp
	
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		# Sanity check
		if !is_on_floor():
			print("why")
			assert(false)



