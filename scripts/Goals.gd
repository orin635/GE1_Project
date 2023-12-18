extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body is RigidBody3D:
		body.global_transform.origin = Vector3(0,5,0)
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		print("SCORE!!!!")
