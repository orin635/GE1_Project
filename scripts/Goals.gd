extends Node3D

signal goalScored

func _on_area_3d_body_entered(body):
	if body is RigidBody3D:
		body.global_transform.origin = Vector3(0, 5, 0)
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		emit_signal("goalScored")
