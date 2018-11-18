extends KinematicBody2D

const GRAV = 500000		# Gravitational constant
const RUN_SPEED = 3000	# Speed of player running movement
const FLY_SPEED = 3		# Speed of player flying movement
const JUMP_SPEED = 300	# Speed of player jump
const GROUND_FRICTION = 0.8

export (bool) var linearGrav = true
# Position of current attractive entity
export (Vector2) var planet = Vector2();


# Gravity debug arrow
onready var arrow = $arrow

var gravVec = Vector2()

var velocity = Vector2(0, 0)

var on_ground = false

func _ready():
    pass

func get_input():
    var left = Input.is_action_pressed("ui_left")
    var right = Input.is_action_pressed("ui_right")
    var jump = Input.is_action_pressed("ui_select")
    
    var up = Vector2(0, -1)
    
    if on_ground && jump:
        velocity += up.rotated(rotation) * JUMP_SPEED
        
        
    var move = Vector2()
    if left:
        move += up.rotated(rotation - PI/2)
    if right:
        move += up.rotated(rotation + PI/2)

    velocity += move * 20

#	if on_ground:
#		if jump:
#			velocity += move * 10
#		else:
#			velocity += move * RUN_SPEED
#	else:
#		velocity += move * FLY_SPEED
    


func _physics_process(delta):
    if not linearGrav:
        # A global normalised vector pointing towards the attractive force
        gravVec = (planet - position).normalized()
        
        # Rotation to point towards the attractive force
        var rotation_angle = Vector2(0, 1).angle_to(gravVec)
        # Rotate the kinematic body so the bottom faces the force
        rotation = rotation_angle
        # Update the arrow to point like the gravity vector
        arrow.global_rotation = rotation_angle + PI
        
        # Force due to gravity to apply to velocity
    #	var gravforce = gravVec * GRAV / position.distance_squared_to(planet)
        
    else:
        gravVec = Vector2(0, 1)
    
    var gravforce = gravVec * 9.8
    velocity += gravforce
    
    get_input()
    
    # Move and detect collisions
    var collision = move_and_collide(velocity * delta)
    
    # Check if we are on the ground
    if collision && collision.collider.is_in_group("ground"):
#		velocity.x = 0
#		velocity.y = 0
        velocity = velocity.slide(collision.normal) * GROUND_FRICTION
        on_ground = true
    else:
        on_ground = false
