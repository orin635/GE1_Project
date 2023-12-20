extends CharacterBody3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rotation_speed = 5
var movement_speed = 9
var acceleration = 6.0
var jump_speed = 8

var ball = null
var player = null
var mode = "default"
var default_keeper_position
var default_keeper_rotation

@onready var keeper = $Body


#Animation vars
@onready var Body = $Body
@onready var lWing = $Body/L_Wing
@onready var rWing = $Body/R_Wing
@onready var lFoot = $Body/L_Foot
@onready var rFoot = $Body/R_Foot
var default_x_rotation
var default_lfoot_origin
var default_rfoot_origin
var default_lwing_origin
var default_rwing_origin
var default_lwing_z_rotation
var default_rwing_z_rotation
var wing_rotate_direction = 1
var foot_rotate_direction = 1
var defend_mode = false



func _ready():
	default_keeper_position = keeper.global_transform.origin
	default_keeper_rotation = keeper.rotation
	default_x_rotation = Body.rotation.x
	default_lfoot_origin = lFoot.transform.origin
	default_rfoot_origin = rFoot.transform.origin
	default_lwing_origin = lWing.transform.origin
	default_rwing_origin = rWing.transform.origin
	default_lwing_z_rotation = lWing.rotation.z
	default_rwing_z_rotation = rWing.rotation.z


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _process(delta):
	if(ball != null and player != null):
		var direction_from_keeper_to_ball = ball.global_transform.origin - keeper.global_transform.origin
		var direction_from_keeper_to_default_position = default_keeper_position - keeper.global_transform.origin
		var distance_from_keeper_to_ball = direction_from_keeper_to_ball.length()
		var distance_from_player_to_ball = (player.global_transform.origin - ball.global_transform.origin).length()
		var distance_from_keeper_to_default_position = direction_from_keeper_to_default_position.length()
		
		#If not default always look at the ball
		if mode != "default":
			look_at(ball.global_transform.origin, Vector3.UP)
			rotation.z = default_keeper_rotation.z
			rotation.x = default_keeper_rotation.x
			rotation.y = lerp_angle(rotation.y, ball.global_transform.origin.y, rotation_speed * delta)
		
		
		#If mode is attack(charge at ball regardless)
		if mode == "attack":
			defend_mode = false
			#Move towards ball
			var target_vel = direction_from_keeper_to_ball.normalized() * movement_speed
			velocity = lerp(velocity, target_vel, acceleration * delta)
			#If closer than 2m to ball kick it away
			if distance_from_keeper_to_ball < 2:
				hit_ball(direction_from_keeper_to_ball)
		
		#If mode is defend(charge at ball if closer to ball than player, else position self between ball and goal
		elif mode == "defend":
			#If the player is closer to the ball (position self in defence)
			if(distance_from_keeper_to_ball > distance_from_player_to_ball):
				defend_mode = true
				if(distance_from_keeper_to_default_position < 7):
					var target_vel = direction_from_keeper_to_ball.normalized() * movement_speed
					target_vel.y = 0
					velocity = lerp(velocity, target_vel, acceleration * delta)
				else:
					var target_vel = direction_from_keeper_to_default_position.normalized() * movement_speed
					target_vel.y = 0
					velocity = lerp(velocity, target_vel, acceleration * delta)
			
			
			#If keeper is closer to the ball (run and kick ball away)
			if(distance_from_keeper_to_ball < distance_from_player_to_ball):
				defend_mode = false
				var target_vel = direction_from_keeper_to_ball.normalized() * movement_speed
				target_vel.y = 0
				velocity = lerp(velocity, target_vel, acceleration * delta)
				#If ball is above keeper jump
				if distance_from_keeper_to_ball < 5 and ball.global_transform.origin.y > 2.5 and is_on_floor():
					velocity.y = jump_speed
				#If closer than 2m to ball kick it away
				if distance_from_keeper_to_ball < 2:
					hit_ball(direction_from_keeper_to_ball)
		
		#If mode is look
		elif mode == "look" or mode == "default":
			defend_mode = false
			#Run towards default position
			if distance_from_keeper_to_default_position > 1:
				var target_vel = direction_from_keeper_to_default_position.normalized() * movement_speed
				velocity = lerp(velocity, target_vel, acceleration * delta)

				#Rotate towards default position
				look_at(default_keeper_position, Vector3.UP)
				rotation.z = default_keeper_rotation.z
				rotation.x = default_keeper_rotation.x
				rotation.y = lerp_angle(rotation.y, default_keeper_position.y, rotation_speed * delta)
			else:
				velocity = Vector3.ZERO
			#If default
			if mode == "default" and distance_from_keeper_to_default_position < 1:
				rotation = default_keeper_rotation
				lerp_angle(rotation.y,default_keeper_rotation.y, rotation_speed * delta)
	
	animation(velocity, delta)

func hit_ball(direction_from_keeper_to_ball):
	var hit_direction = direction_from_keeper_to_ball 
	hit_direction.normalized()
	if hit_direction.z <= 0.6:
		hit_direction.z = 0.6
	var hit_force = 8
	if is_on_floor() == false:
		hit_force = 2
	var impulse = hit_direction * hit_force
	ball.apply_central_impulse(impulse)


func animation(velocity, delta):
	if velocity.length() > 1.0:
		if(is_on_floor()):
			#Rotate Character forward relative to speed
			Body.rotation.x = default_x_rotation - remap(velocity.length(),0, 16,0, 0.45)
			#Swing the arms
			#If arms reach max rotation, rotate back
			if defend_mode == false:
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
	if defend_mode == true:
		lWing.rotation.x = default_x_rotation
		rWing.rotation.x = default_x_rotation
		lWing.rotation.z = default_lwing_z_rotation - 80
		rWing.rotation.z = default_rwing_z_rotation - 80
		rWing.transform.origin.x = 0.5
		lWing.transform.origin.x = -0.5  
	else:
		lWing.rotation.z = default_lwing_z_rotation
		rWing.rotation.z = default_rwing_z_rotation
		lWing.transform.origin = default_lwing_origin
		rWing.transform.origin = default_rwing_origin
		lWing.transform.origin = default_lwing_origin
		rWing.transform.origin = default_rwing_origin



#Look Areas
func _on_look_area_body_entered(body):
	if body is RigidBody3D:
		ball = body
		mode = "look"
	if body.is_in_group("player"):
		player = body

func _on_look_area_body_exited(body):
	mode = "default"



#Defend Area
func _on_defend_area_body_entered(body):
	if body is RigidBody3D:
		mode = "defend"

func _on_defend_area_body_exited(body):
	if body is RigidBody3D:
		mode = "look"



#Attack Area
func _on_attack_area_body_entered(body):
	if body is RigidBody3D:
		mode = "attack"

func _on_attack_area_body_exited(body):
	if body is RigidBody3D:
		mode = "defend"


#Load Area
func _on_load_area_body_entered(body):
	if body is RigidBody3D:
		ball = body
	if body.is_in_group("player"):
		player = body
