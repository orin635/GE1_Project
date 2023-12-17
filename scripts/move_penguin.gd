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
@onready var model = $Body


#Animation vars
@onready var lWing = $L_Wing
@onready var Body = $Body

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = gravity * 1.8
	


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
	#animation(velocity)


func _physics_process(delta):
	velocity.y += -gravity * delta
	move_and_slide()
	
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	


func animation(velocity):
	var transform = Body.transform#
	transform.basis = transform.basis.rotated(Vector3(0, 1, 0), deg_to_rad(25))

	# Set the updated transform to the mesh instance
	Body.transform = transform

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
