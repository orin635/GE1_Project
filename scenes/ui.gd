extends CanvasLayer

@onready var score_label = $Control/MarginContainer/Score
var score = 0

func _ready():
	var goal_node = get_node("/root/Node3D/Goals")

func update_score():
	score += 1
	score_label.text = "Score : " + str(score)



func _on_goals_goal_scored():
	print("SCORE!!!!")
	update_score()
