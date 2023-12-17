extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed = 4.5  # movement speed
@export var jump_speed = 8.0  # determines jump height
@export var mouse_sensitivity = 0.002  # turning speed
@export var acceleration = 4.0#
@export var rotation_speed = 12.0
var push_force = 80.0
@onready var spring_arm = $SpringArm3D
@onready var model = $Body

var push = 0.1



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = gravity * 1.8
	
func get_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy

func _physics_process(delta):
	velocity.y += -gravity * delta
	get_input(delta)
	move_and_slide()
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	

 

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed



