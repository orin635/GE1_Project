extends CanvasLayer

@onready var score_label = $Control/MarginContainer/Score
@onready var stamina_bar = $Control/MarginContainer2/ProgressBar
var score = 0

func _ready():
	var goal_node = get_node("/root/Node3D/Goals")
	score_label.text = "Score : 0"

func update_score():
	score += 1
	score_label.text = "Score : " + str(score)



func _on_goals_goal_scored():
	update_score()


func _on_character_body_3d_stamina_update(stamina):
	stamina_bar.value = stamina
