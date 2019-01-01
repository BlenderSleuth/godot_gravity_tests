extends KinematicBody

export (int) var run_speed = 8
export (int) var fly_speed = 1
export (int) var max_run_speed = 15
export (float) var run_damp = 0.85
export (float) var fly_damp = 0.98

export (int) var jump_speed = 100
export (float) var jump_time = 0.24 # Time in seconds for advanced control over jump

onready var player_camera = $PlayerCamera
onready var front_camera = $"../FrontCamera"


# Velocity in global coordinates
var velocity = Vector3()

var planet_position = Vector3()

export var gravity = 10

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
func jump(delta):
	pass

func get_movement(delta):
	# Input events
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var forward = Input.is_action_pressed("ui_up")
	var backward = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_pressed('ui_select')

	# Movement velocity in local coordinates
	var move = Vector3()

	if jump:
		jump(delta)
	else:
		jumping = false
	
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
	move = move.normalized() * clamp(move.length(), -max_run_speed, max_run_speed)
	
	return move


func _physics_process(delta):
	# Vector in the direction of gravity
	var grav_vec = (planet_position - transform.origin).normalized()
	
	# Feet of player
	var down = -transform.basis.y
	
	# Rotation axis, perpindicular to the down direction and gravity direction
	var rot_axis = down.cross(grav_vec)

	# Check nothing dumb happened
	if (rot_axis.length_squared() == 0):
		var up = transform.basis.z
		rot_axis = up
		print("u wot")
	else:
		rot_axis = rot_axis.normalized()
	
	# Find the angle to rotate
	var dot = clamp(down.dot(grav_vec), -1, 1)
	var angle = acos(dot)
	
	# Rotate player so the local down direction is in the direction of gravity
	transform.basis = transform.basis.rotated(rot_axis, angle)
	transform = transform.orthonormalized()
	
	# Apply input movement
	var movement = get_movement(delta)
	velocity += transform.basis * movement
	
	# Add gravity 
	velocity += grav_vec * gravity
	
	# Apply friction or air resistance
	var damp = run_damp if is_on_floor() else fly_damp
	
	# Move player
	velocity = move_and_slide(velocity, -grav_vec) * damp
	
#	print(is_on_floor())