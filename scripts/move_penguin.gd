extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 8
@export var default_speed = 8 
@export var jump_speed = 8.0 
@export var max_speed = 16
@export var mouse_sensitivity = 0.002 
@export var acceleration = 6.0#
@export var rotation_speed = 12.0
@onready var spring_arm = $SpringArm3D


#Animation vars
@onready var Body = $Body
@onready var lWing = $Body/L_Wing
@onready var rWing = $Body/R_Wing
@onready var lFoot = $Body/L_Foot
@onready var rFoot = $Body/R_Foot
var default_x_rotation
var default_lfoot_origin
var default_rfoot_origin
var wing_rotate_direction = 1
var foot_rotate_direction = 1
var foot_points = 100
var foot_step = 0
var foot_radius = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = gravity * 1.8
	default_x_rotation = Body.rotation.x
	default_lfoot_origin = lFoot.transform.origin
	default_rfoot_origin = rFoot.transform.origin


func get_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	
	if Input.is_action_pressed("run"):
		speed = max_speed
		acceleration = 9
	else:
		speed = default_speed
		acceleration = 6
	
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy


func _process(delta):
	get_input(delta)
	animation(velocity, delta)


func _physics_process(delta):
	velocity.y += -gravity * delta
	move_and_slide()
	


func animation(velocity, delta):
	
	if velocity.length() > 1.0:
		Body.rotation.y = lerp_angle(Body.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
		if(is_on_floor()):
			#Rotate Character forward relative to speed
			Body.rotation.x = default_x_rotation - remap(velocity.length(),0, 16,0, 0.45)
			#Swing the arms
			#If arms reach max rotation, rotate back
			if((default_x_rotation - (lWing.rotation.x * wing_rotate_direction))< -0.9):
				wing_rotate_direction = wing_rotate_direction * -1
			lWing.rotation.x = lWing.rotation.x + (remap(velocity.length(),0, 16,0, 0.05)*wing_rotate_direction)
			rWing.rotation.x = rWing.rotation.x + (remap(velocity.length(),0, 16,0, 0.05)*wing_rotate_direction)
			
			#Swing the feet
			if((default_x_rotation - (lFoot.rotation.x * foot_rotate_direction))< -0.9):
				foot_rotate_direction = foot_rotate_direction * -1
			lFoot.rotation.x = lFoot.rotation.x + (remap(velocity.length(),0, 16,0, 0.05)*foot_rotate_direction)
			rFoot.rotation.x = rFoot.rotation.x + (remap(velocity.length(),0, 16,0, 0.05)*foot_rotate_direction*-1)
	else :
		Body.rotation.x = default_x_rotation
		lWing.rotation.x = default_x_rotation
		rWing.rotation.x = default_x_rotation
		rFoot.rotation.x = default_x_rotation
		lFoot.rotation.x = default_x_rotation




func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed




#Check prime collision area
func _on_area_3d_body_entered(body):
	if body is RigidBody3D:  # Check if the entered body is the ball (replace with your desired type)
		var character_position = global_transform.origin
		var ball_position = body.global_transform.origin
		var hit_direction = (ball_position - character_position).normalized()
		
		#Calculate penguin speed to get force of kick
		var penguin_speed = velocity.length()
		var push_force = penguin_speed * 3
		var hit_force = hit_direction * push_force
		
		
		# Apply an impulse force to the ball in the calculated direction
		body.apply_central_impulse(hit_force)
