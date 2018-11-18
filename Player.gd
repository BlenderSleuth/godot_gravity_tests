extends RigidBody2D

const GRAV = 100000
const MOVE_SPEED = 2
const JUMP_SPEED = 20

export (Vector2) var planet = Vector2();

var on_ground = false

onready var arrow = $arrow

var gravVec = Vector2()


func _ready():
    pass

func _integrate_forces(state):
    gravVec = (planet - position).normalized()
    
    var global_rotation_angle = Vector2(0, -1).angle_to(gravVec)
    arrow.global_rotation = global_rotation_angle
    
    var cur_dir = Vector2(0, 1).rotated(global_rotation)
    var rotation_angle = cur_dir.angle_to(gravVec)
    state.angular_velocity = (rotation_angle / state.get_step())
    
    var gravforce = gravVec * GRAV / position.distance_squared_to(planet)
    state.linear_velocity += gravforce
    
    var moveVec = Vector2(MOVE_SPEED, 0).rotated(rotation)
    
    if Input.is_action_pressed("ui_left"):
        state.linear_velocity -= moveVec
    if Input.is_action_pressed("ui_right"):
        state.linear_velocity += moveVec
        

func _process(delta):
    
    if Input.is_action_pressed("ui_jump"):
        apply_impulse(position, Vector2(0, -JUMP_SPEED).rotated(rotation))
