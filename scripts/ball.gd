extends RigidBody3D

var velocity_limit = 35

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if(linear_velocity.length() > velocity_limit):
		linear_velocity = linear_velocity.normalized() * velocity_limit
	

