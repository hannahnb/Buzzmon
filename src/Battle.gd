extends Control

signal textbox_closed

@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

var specialMoves = {
	"BA": ["Sunk Cost Fallacy", "Rizz"],
	"CM": ["Binary Beam","Self-Love"],
	"AE": ["Aerodynamic Assault", "Countermeasures"],
	"ME": ["Assault: Downgrade", "Defense: Downgrade"]
}

var specialMovesDamage = {
	"Sunk Cost Fallacy": 0, 
	"Powerpoint Push": 20, 
	"Rizz": 0,
	"Binary Beam": 100,
	"Self-Love": 10, 
	"Digital Dash": 0,
	"Orbital Strike": 100, 
	"Aerodynamic Assault": 0, 
	"Countermeasures": 0,
	"Mechanical Mayhem": 20, 
	"Assault: Downgrade": 0, 
	"Defense: Downgrade": 0
}
#var major = "Engineer"

func _ready():
	if (GlobalStats.buzz_count == 3):
		$ActionsPanel/Actions/Swap.visible = true
	resetStats()
	if GlobalStats.curr_battle == 3:
		enemy.damage = 100
		enemy.health = 1000
		set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
		current_enemy_health = 1000
		
	
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	if GlobalStats.major == "ME":
		$Player.texture = load("res://sprites/EngineerFrontSmall.png")
		$Player.flip_h = true
	elif GlobalStats.major == "BA":
		$Player.texture = load("res://sprites/BusinessFrontSmall.png")
		$Player.flip_h = true
	elif GlobalStats.major == "AE":
		$Player.texture = load("res://sprites/AEFrontSmall.png")
		$Player.flip_h = false
	elif GlobalStats.major == "CM":
		$Player.texture = load("res://sprites/CMFrontSmall.png")
		$Player.flip_h = true
		
	$ActionsPanel/Actions/Special1.text = specialMoves[GlobalStats.major][0]
	$ActionsPanel/Actions/Special2.text = specialMoves[GlobalStats.major][1]
#	$ActionsPanel/Actions/Special3.text = specialMoves[GlobalStats.major][2]
#	$ActionsPanel/Actions/Special4.text = specialMoves[GlobalStats.major][3]
	
	$Textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A %s is challenging you!" % enemy.name.to_upper())
	await self.textbox_closed
	$ActionsPanel.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$Textbox.show()
	$Textbox/Label.text = text

func enemy_turn():
	if (enemy.stunned > 0):
		enemy.stunned = enemy.stunned - 1
		display_text("%s is too rizzed up to act!" % enemy.name)
		await self.textbox_closed
		$ActionsPanel.show()
	else:
		
		display_text("%s launches at you fiercely!" % enemy.name)
		await self.textbox_closed
		
		if is_defending:
			is_defending = false
			$AnimationPlayer.play("mini_shake")
			await $AnimationPlayer.animation_finished
			display_text("You defended successfully!")
			await self.textbox_closed
		else:
			current_player_health = max(0, current_player_health - (enemy.damage / State.defense))
			set_health($PlayerPanel/PlayerData/ProgressBar, current_player_health, State.max_health)
			$AnimationPlayer.play("shake")
			await $AnimationPlayer.animation_finished
			display_text("%s dealt %d damage!" % [enemy.name, enemy.damage / State.defense])
			await self.textbox_closed
			if current_player_health <= 0:
				display_text("You have been defeated.")
				await self.textbox_closed
				get_tree().change_scene_to_file("res://src/Main Menu.tscn")
		$ActionsPanel.show()

func resetStats():
	State.damage = 30
	State.defense = 1
	enemy.damage = 20
	enemy.stunned = 0
	enemy.defense = 1

func _on_Special_pressed():
#	print($ActionsPanel/Actions/.visible)
	$ActionsPanel/Actions/Attack.visible = !$ActionsPanel/Actions/Attack.visible
	$ActionsPanel/Actions/Defend.visible = !$ActionsPanel/Actions/Defend.visible
	$ActionsPanel/Actions/Special.visible = !$ActionsPanel/Actions/Special.visible
	$ActionsPanel/Actions/Special1.visible = !$ActionsPanel/Actions/Special1.visible
	$ActionsPanel/Actions/Special2.visible = !$ActionsPanel/Actions/Special2.visible
#	$ActionsPanel/Actions/Special3.visible = !$ActionsPanel/Actions/Special3.visible
#	$ActionsPanel/Actions/Special4.visible = !$ActionsPanel/Actions/Special4.visible
	$ActionsPanel/Actions/Back.visible = !$ActionsPanel/Actions/Back.visible
	if GlobalStats.buzz_count == 3:
		$ActionsPanel/Actions/Swap.visible = !$ActionsPanel/Actions/Swap.visible
#	print(GlobalStats.major)
#	print($ActionsPanel/Actions/Art.visible)
#	display_text("Got away safely!")
#	yield(self, "textbox_closed")
#	yield(get_tree().create_timer(0.25), "timeout")
#	get_tree().quit()

func _on_Special1_pressed():
	specialMoves($ActionsPanel/Actions/Special1.text)
	print("yes!")
	
func _on_Special2_pressed():
	specialMoves($ActionsPanel/Actions/Special2.text)
	
func _on_Special3_pressed():
	specialMoves($ActionsPanel/Actions/Special3.text)
	
func _on_Special4_pressed():
	specialMoves($ActionsPanel/Actions/Special4.text)
	
func specialMoves(moveName: String):
#	var moves = specialMoves[GlobalStats.major]
	var damage = specialMovesDamage[moveName] * enemy.defense
	if moveName == "Sunk Cost Fallacy":
		display_text("You used Sunk Cost Fallacy!")
		await self.textbox_closed
		var specialDamage = (((current_enemy_health / current_player_health) * State.damage)) * enemy.defense
		current_enemy_health = max(0, current_enemy_health - specialDamage)
		set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)

		$AnimationPlayer.play("enemy_damaged")
		await $AnimationPlayer.animation_finished
		
		display_text("You dealt %d relative damage!" % specialDamage)
		await self.textbox_closed
	elif moveName == "Rizz":
		display_text("You used Rizz!")
		await self.textbox_closed
		
		if enemy.stunned > 0:
			display_text("Your rizzing failed!")
			await self.textbox_closed
		else:
			enemy.stunned = 2
			
			$AnimationPlayer.play("enemy_damaged")
			await $AnimationPlayer.animation_finished
			
			display_text("You rizzed %s!" % enemy.name)
			await self.textbox_closed
	elif moveName == "Binary Beam":
		display_text("You used Binary Beam!")
		await self.textbox_closed
		
		current_enemy_health = max(0, current_enemy_health - damage)
		set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)

		$AnimationPlayer.play("enemy_damaged")
		await $AnimationPlayer.animation_finished
		
		display_text("You dealt %d damage!" % damage)
		await self.textbox_closed
	elif moveName == "Self-Love":
		display_text("You used Self-Love!")
		await self.textbox_closed
		
		State.max_health = 100
#		set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
		set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
		State.current_health += 65
		if State.current_health > 100:
			State.current_health = 100
		set_health($PlayerPanel/PlayerData/ProgressBar, State.current_health, State.max_health)
		current_player_health += 65
		if current_player_health > 100:
			current_player_health = 100
		
		current_enemy_health = max(0, current_enemy_health - damage)
		set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
		
		display_text("You recovered 65 health and expanded your health pool to 100!")
		await self.textbox_closed
		
	elif moveName == "Aerodynamic Assault":
		display_text("You used Aerodynamic Assault!")
		await self.textbox_closed
		
		State.damage *= 2
		
		display_text("You doubled your damage!")
		await self.textbox_closed
	elif moveName == "Countermeasures":
		display_text("You deployed aircraft countermeasures!")
		await self.textbox_closed
		
		State.defense *= 2
		
		display_text("You doubled your defense!")
		await self.textbox_closed
	elif moveName == "Assault: Downgrade":
		display_text("You used Assault: Downgrade!")
		await self.textbox_closed
		
		enemy.damage /= 2
		
		$AnimationPlayer.play("enemy_damaged")
		await $AnimationPlayer.animation_finished
		
		display_text("You halved the enemy's damage!")
		await self.textbox_closed
	elif moveName == "Defense: Downgrade":		
		display_text("You used Defense: Downgrade!")
		await self.textbox_closed
		
		enemy.defense *= 2
		
		$AnimationPlayer.play("enemy_damaged")
		await $AnimationPlayer.animation_finished
		
		display_text("You halved the enemy's damage!")
		await self.textbox_closed
#	"Sunk Cost Fallacy": 0, 
#	"Powerpoint Push": 20, 
#	"Rizz": 0,
#	"Binary Beam": 50,
#	"Self-Love": 10, 
#	"Digital Dash": 0,
#	"Orbital Strike": 100, 
#	"Aerodynamic Assault": 0, 
#	"Countermeasures": 0,
#	"Mechanical Mayhem": 20, 
#	"Assault: Downgrade": 0, 
#	"Defense Systems: Downgrade": 0
	checkVictory()

func _on_Swap_pressed():
	$ActionsPanel/Actions/Attack.visible = !$ActionsPanel/Actions/Attack.visible
	$ActionsPanel/Actions/Defend.visible = !$ActionsPanel/Actions/Defend.visible
	$ActionsPanel/Actions/Special.visible = !$ActionsPanel/Actions/Special.visible
	$ActionsPanel/Actions/Major1.visible = !$ActionsPanel/Actions/Major1.visible
	$ActionsPanel/Actions/Major2.visible = !$ActionsPanel/Actions/Major2.visible
	$ActionsPanel/Actions/Major3.visible = !$ActionsPanel/Actions/Major3.visible
	$ActionsPanel/Actions/Major4.visible = !$ActionsPanel/Actions/Major4.visible

func _on_Major1_pressed():
	display_text("Swapped to BA major!")
	await self.textbox_closed
	GlobalStats.major = "BA"
	$ActionsPanel/Actions/Special1.text = specialMoves[GlobalStats.major][0]
	$ActionsPanel/Actions/Special2.text = specialMoves[GlobalStats.major][1]
	_on_Swap_pressed()
	$ActionsPanel.show()
func _on_Major2_pressed():
	display_text("Swapped to CM major!")
	await self.textbox_closed
	GlobalStats.major = "CM"
	$ActionsPanel/Actions/Special1.text = specialMoves[GlobalStats.major][0]
	$ActionsPanel/Actions/Special2.text = specialMoves[GlobalStats.major][1]
	_on_Swap_pressed()
	$ActionsPanel.show()
func _on_Major3_pressed():
	display_text("Swapped to AE major!")
	await self.textbox_closed
	GlobalStats.major = "AE"
	$ActionsPanel/Actions/Special1.text = specialMoves[GlobalStats.major][0]
	$ActionsPanel/Actions/Special2.text = specialMoves[GlobalStats.major][1]
	_on_Swap_pressed()
	$ActionsPanel.show()
func _on_Major4_pressed():
	display_text("Swapped to ME major!")
	await self.textbox_closed
	GlobalStats.major = "ME"
	$ActionsPanel/Actions/Special1.text = specialMoves[GlobalStats.major][0]
	$ActionsPanel/Actions/Special2.text = specialMoves[GlobalStats.major][1]
	_on_Swap_pressed()
	$ActionsPanel.show()

func checkVictory():
	if current_enemy_health == 0:
		display_text("%s was defeated!" % enemy.name)
		await self.textbox_closed
		display_text("You've beat me fair and square.")
		await self.textbox_closed
		
		if GlobalStats.curr_battle < 3:
			display_text("Take this, you've earned it.")
			if enemy.name == "Business Major":
				$Buzzcard.texture = load("res://sprites/buzzcards/businessbuzzcard.png")
				$Buzzcard.scale = Vector2(0.25, 0.25)
			if enemy.name == "Computational Media Major":
				$Buzzcard.texture = load("res://sprites/buzzcards/CMbuzzcard.png")
				$Buzzcard.scale = Vector2(0.15, 0.15)
				$Buzzcard.position = Vector2(180, 200)
			if enemy.name == "Mechanical Engineer":
				$Buzzcard.texture = load("res://sprites/buzzcards/MEbuzzcard.png")
				$Buzzcard.scale = Vector2(0.15, 0.15)
				$Buzzcard.position = Vector2(180, 200)
			if enemy.name == "Aerospace Engineer":
				$Buzzcard.texture = load("res://sprites/buzzcards/AEbuzzcard.png")
				$Buzzcard.scale = Vector2(0.15, 0.15)
				$Buzzcard.position = Vector2(180, 200)
			$Buzzcard.show()
			await self.textbox_closed
		
			$Yes.show()
			$No.show()
			$Yes.grab_focus()
			display_text("Take Buzzcard?")
			await self.textbox_closed
		
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		
		await get_tree().create_timer(0.25).timeout
		GlobalStats.curr_battle += 1
		if GlobalStats.curr_battle < 3:
			get_tree().change_scene_to_file("res://src/ChallengerCard.tscn")
		elif GlobalStats.curr_battle == 3:
			get_tree().change_scene_to_file("res://src/BuzzIntro.tscn")
		else:
			get_tree().change_scene_to_file("res://src/Main Menu.tscn")

	enemy_turn()
func _on_Attack_pressed():
	display_text("You launch your assault!")
	await self.textbox_closed
	var damage = State.damage * enemy.defense
	current_enemy_health = max(0, current_enemy_health - damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)

	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	display_text("You dealt %d damage!" % damage)
	await self.textbox_closed
	
	checkVictory()

func _on_Defend_pressed():
	is_defending = true
	
	display_text("You prepare defensively!")
	await self.textbox_closed
	
	await get_tree().create_timer(0.25).timeout
	
	enemy_turn()
	
#func _on_Defense_pressed():
#	is_defending = true
#
#	display_text("You prepare defensively!")
#	yield(self, "textbox_closed")
#
#	yield(get_tree().create_timer(0.25), "timeout")
#
#	enemy_turn()


func _on_Yes_pressed():
	$Yes.disabled = true
	GlobalStats.buzz_count += 1
	print(GlobalStats.buzz_count)
	
func _on_No_pressed():
	$No.disabled = true
