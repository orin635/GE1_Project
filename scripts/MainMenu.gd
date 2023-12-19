extends Control

var audio_player : AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_player = $AudioStreamPlayer2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("jump"):
		var new_audio_stream : AudioStream = preload("res://resources/epicbackgroundmusic.mp3")
	# Set the new audio stream
		audio_player.stream = new_audio_stream
		# Play the new audio stream
		audio_player.play()



func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_option_button_pressed():
	pass # Replace with function body.


func _on_exit_button_pressed():
	get_tree().quit()
