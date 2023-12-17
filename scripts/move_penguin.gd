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

var cooldown_timer = 0.0
var cooldown_duration = 0.1

var run_cooldown_timer = 0.0
var run_cooldown_duration = 5

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
	animation(velocity)


# Calculate collisions
func handle_collision(collision):
	var normal = collision.get_normal()
	var impulse_direction = -normal
	print(impulse_direction)
	# Calculate push force based on penguin's speed
	var penguin_speed = velocity.length()
	var push_force = penguin_speed * 3
	var hit_force = impulse_direction * push_force
	hit_force.y = 3
	collision.get_collider().apply_central_impulse(hit_force)
	cooldown_timer = cooldown_duration


func _physics_process(delta):
	cooldown_timer -= delta
	run_cooldown_timer -= delta
	velocity.y += -gravity * delta
	move_and_slide()
	
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	
	
	# Collect collisions
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D and cooldown_timer <= 0.0:
			handle_collision(c)


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



