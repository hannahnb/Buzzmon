extends Node2D

func _ready():
	$Button.grab_focus();
	if GlobalStats.major == "CM":
		if GlobalStats.curr_battle == 0:
			$Sprite2D.texture = load("res://sprites/BusinessChallengeScreen.png")
		if GlobalStats.curr_battle == 1:
			$Sprite2D.texture = load("res://sprites/AEChallengeScreen.png")
		if GlobalStats.curr_battle == 2:
			$Sprite2D.texture = load("res://sprites/MEChallengerScreen.png")
	if GlobalStats.major == "ME":
		if GlobalStats.curr_battle == 0:
			$Sprite2D.texture = load("res://sprites/BusinessChallengeScreen.png")
		if GlobalStats.curr_battle == 1:
			$Sprite2D.texture = load("res://sprites/AEChallengeScreen.png")
		if GlobalStats.curr_battle == 2:
			$Sprite2D.texture = load("res://sprites/CMChallengeScreen.png")
	if GlobalStats.major == "AE":
		if GlobalStats.curr_battle == 0:
			$Sprite2D.texture = load("res://sprites/MEChallengerScreen.png")
		if GlobalStats.curr_battle == 1:
			$Sprite2D.texture = load("res://sprites/CMChallengeScreen.png")
		if GlobalStats.curr_battle == 2:
			$Sprite2D.texture = load("res://sprites/BusinessChallengeScreen.png")
	if GlobalStats.major == "BA":
		if GlobalStats.curr_battle == 0:
			$Sprite2D.texture = load("res://sprites/CMChallengeScreen.png")
		if GlobalStats.curr_battle == 1:
			$Sprite2D.texture = load("res://sprites/MEChallengerScreen.png")
		if GlobalStats.curr_battle == 2:
			$Sprite2D.texture = load("res://sprites/AEChallengeScreen.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if GlobalStats.major == "CM":
		get_tree().change_scene_to_file(GlobalStats.cm_opps[GlobalStats.curr_battle])
	if GlobalStats.major == "ME":
		get_tree().change_scene_to_file(GlobalStats.me_opps[GlobalStats.curr_battle])
	if GlobalStats.major == "AE":
		get_tree().change_scene_to_file(GlobalStats.ae_opps[GlobalStats.curr_battle])
	if GlobalStats.major == "BA":
		get_tree().change_scene_to_file(GlobalStats.ba_opps[GlobalStats.curr_battle])
