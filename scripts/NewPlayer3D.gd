extends KinematicBody

export (int) var run_speed = 0.5
export (int) var fly_speed = 1
export (int) var max_run_speed = 10
export (float) var run_damp = 0.85
export (float) var fly_damp = 0.98

export (int) var jump_speed = 100
export (float) var jump_time = 0.24 # Time in seconds for advanced control over jump

# Velocity in global coordinates
var velocity = Vector3()

var planet_position = Vector3()

export var gravity = 10

func _ready():
	
	pass

var jumping = false
func jump(delta):
	pass

func get_input(delta):
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_pressed('ui_select')

	var loc_velocity = Vector3()

	# Slow down velocity 
	loc_velocity.x *= run_damp if is_on_floor() else fly_damp

	if jump:
		jump(delta)
	else:
		jumping = false
	
	# Different speed on ground and in air
	var move_speed = run_speed if is_on_floor() else fly_speed
	if right:
		loc_velocity.x += move_speed
	if left:
		loc_velocity.x -= move_speed
	
	# Make sure player doesn't accelerate too much
	loc_velocity.x = clamp(loc_velocity.x, -max_run_speed, max_run_speed)
	
	return loc_velocity

var frames = 0
func _physics_process(delta):
	var mov_velocity = get_input(delta)
	
	frames += 1
	
	var t = transform
	var grav_vec = (planet_position - t.origin).normalized()
	
	var front = -t.basis.y
	var up = t.basis.z
	
	var look_dir = grav_vec
	
	var rot_axis = front.cross(look_dir)

	if (rot_axis.length_squared() == 0):
		rot_axis = up
	else:
		rot_axis = rot_axis.normalized()
	
	var dot = clamp(front.dot(look_dir), -1, 1)
	var angle = acos(dot)
	
	transform.basis = transform.basis.rotated(rot_axis, angle)
	velocity += mov_velocity.rotated(rot_axis, angle)
	
	velocity += grav_vec * gravity

	
	velocity = move_and_slide(velocity)