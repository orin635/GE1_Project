extends Node3D

signal goalScored

var goalSoundPlayer: AudioStreamPlayer
var stayTime: float = 3.0    # Time to stay at the same volume in seconds
var fadeOutTime: float = 3.0  # Time to fade the sound out in seconds
var timer: float = 0.0

func _ready():
	# Assume that goalSoundPlayer is a child node of this node or set it manually
	goalSoundPlayer = $AudioStreamPlayer

func _on_area_3d_body_entered(body):
	if body is RigidBody3D:
		body.global_transform.origin = Vector3(0, 5, 0)
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		emit_signal("goalScored")
		goalSoundPlayer.play()
		timer = 0.0

func _process(delta):
	if timer < stayTime:
		# Stay at the same volume
		goalSoundPlayer.volume_db = 0.0
	elif timer < stayTime + fadeOutTime:
		# Fade out
		goalSoundPlayer.volume_db = lerp(0.0, -80.0, (timer - stayTime) / fadeOutTime)
	else:
		# Stop playing after the entire sequence
		goalSoundPlayer.stop()

	timer += delta

# Linear interpolation function
func lerp(start, end, weight):
	return start + weight * (end - start)
