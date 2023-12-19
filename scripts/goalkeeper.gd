extends CharacterBody3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ball = null
var rotation_speed = 5
var movement_speed = 5
var default_position
var default_rotation
@onready var goalkeeper = $Body

func _ready():
	default_position = goalkeeper.global_transform.origin
	default_rotation = goalkeeper.rotation

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _process(delta):
	if ball != null:
		var direction_to_ball = ball.global_transform.origin - global_transform.origin
		direction_to_ball.y = 0  # Ignore changes in the Y-axis

		# Use look_at() with the modified direction to rotate only on the Y-axis
		if direction_to_ball.length_squared() > 0:
			look_at(global_transform.origin + direction_to_ball, Vector3.UP)

		# Smoothly interpolate the rotation for a smoother look
		rotation.y = lerp_angle(rotation.y, direction_to_ball.angle_to(Vector3.FORWARD), rotation_speed * delta)
		
		var ball_distance = ball.global_transform.origin.distance_to(default_position)
		if ball_distance < 13:
			velocity = direction_to_ball.normalized() * movement_speed
			
		var distance_from_ball_to_keeper = goalkeeper.global_transform.origin.distance_to(ball.global_transform.origin)
		if(distance_from_ball_to_keeper < 2):
			print("KICK")
	else :
		var direction_to_default_position = default_position - goalkeeper.global_transform.origin
		direction_to_default_position.y = 0
		if direction_to_default_position.length_squared() > 0:
			look_at(global_transform.origin + direction_to_default_position, Vector3.UP)
		rotation.y = lerp_angle(rotation.y, direction_to_default_position.angle_to(Vector3.FORWARD), rotation_speed * delta)
		velocity = direction_to_default_position.normalized() * movement_speed
		
		var distance_to_default = global_transform.origin.distance_to(default_position)
		if(distance_to_default < 1):
			velocity = Vector3.ZERO
			rotation = default_rotation
	
####If ball is closer to keeper than you it runs
####Keeper needs to kick the ball away
###Keeper needs to jump
###If you are closer than keeper then keeper stands between you and goal
###--then keeper puts hands out

func _on_defend_area_body_entered(body):
	if body is RigidBody3D:
		ball = body


func _on_defend_area_body_exited(body):
	if body is RigidBody3D:
		ball = null
