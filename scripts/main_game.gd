extends Node2D

var Dice_Run = 0
var player_or_ai = [true, true, true, true]
var turn = 0
var Dice_Face = 0
var PlayerPosition : Array = [0, 0, 0, 0]
var Player_Path : Array = []
var is_running : bool = false
var one_or_two_map : bool = false
var Last_Won : String
var time_running : float = 0
var last_updated = 0
var file_path = "res://save_score.data"

var Players = {
	0: "Yellow",
	1: "Blue",
	2: "Red",
	3: "Green"
}

var Dice_Position = {
	0: Vector2(122, 939),
	1: Vector2(118, 52),
	2: Vector2(455, 52),
	3: Vector2(452, 937)
}

var two_Ladder_Location = {
	4: 23,
	8: 28,
	14: 46,
	30: 49,
	40: 58,
	56: 76,
	70: 72,
	80: 98,
	89: 93
}
var two_Snake_Location = {
	99: 67,
	91: 1,
	79: 7,
	60: 24,
	55: 10
}

var one_Ladder_Location = {
	2: 18,
	9: 28,
	25: 47,
	30: 50,
	39: 41,
	45: 57,
	51: 73,
	65: 85,
	79: 98,
	89: 91
}

var one_Snake_Location = {
	99: 81,
	97: 58,
	95: 75,
	93: 67,
	90: 70,
	66: 46,
	62: 60,
	52: 33,
	38: 17,
	27: 5
}

func _ready() -> void:
	load_game()
	$BackGroundMusic.play()
	$StartScreen.start.connect(start_game)
	$StartScreen.oneplayer.connect(one_player)
	$StartScreen.twoplayer.connect(two_player)
	$StartScreen.threeplayer.connect(three_player)
	$StartScreen.fourplayer.connect(four_player)
	$endScreen.startScreen.connect(go_back_to_startScreen)
	$Dice_Animation.hide()
	$Dice_Drawed.hide()
	$StartScreen/last_winner.text = str(Last_Won) + " won last time"
	
	if one_or_two_map:
		$oneboard/Path.hide()
		$oneboard/Playing_Board.hide()
		Player_Path = [$oneboard/Path/Yellow_Player, $oneboard/Path/Blue_Player, $oneboard/Path/Red_Player, $oneboard/Path/Green_Player]
		$twoboard.hide()
	else:
		$twoboard/Path.hide()
		$twoboard/Playing_Board.hide()
		$oneboard.hide()
		Player_Path = [$twoboard/Path/Yellow_Player, $twoboard/Path/Blue_Player, $oneboard/Path/Red_Player, $twoboard/Path/Green_Player]
	$endScreen.hide()

func start_game() -> void:
	is_running = true
	$Dice_Drawed.show()
	if one_or_two_map:
		$oneboard/Path.show()
		$oneboard/Playing_Board.show()
	else:
		$twoboard/Path.show()
		$twoboard/Playing_Board.show()
	$StartScreen.hide()
	Dice_Mover(turn)
	
	if not is_running:
		return
	if player_or_ai[turn]:
		await get_tree().create_timer(1.0).timeout
		ai_turn()
	else:
		Dice_Run = 1

func _on_dice_drawed_pressed() -> void:
	if Dice_Run == 0:
		return
	if $StartScreen.visible:
		return
	if not is_running:
		return
	$Dice_Roll.play()
	$Dice_Drawed.hide()
	$Dice_Animation.show()
	$Dice_Animation.play("dice_draw")
	Dice_Run = 0
func ai_turn() -> void:
	$Dice_Roll.play()
	$Dice_Drawed.hide()
	$Dice_Animation.show()
	$Dice_Animation.play("dice_draw")

func _on_dice_animation_finished() -> void:
	if not is_running:
		return
	randomize()
	Dice_Face = randi_range(0, 5)
	$Dice_Animation.hide()
	$Dice_Drawed.show()
	$Dice_Drawed.set_frame(Dice_Face)
	var dice_value = Dice_Face + 1
	$Dice_Drawed/Dice_Drawed.hide()
	if PlayerPosition[turn] == 0:
		if dice_value == 1:
			PlayerPosition[turn] = 1
			var Path_Point = 0
			if one_or_two_map:
				Path_Point = $oneboard/Path.get_curve().get_point_position(0)
			else:
				Path_Point = $twoboard/Path.get_curve().get_point_position(0)
			Player_Path[turn].position = set_offset_for_pawns(Path_Point, turn)
	else:
		await _move_player(turn, dice_value)
	await get_tree().create_timer(0.5).timeout
	if PlayerPosition[turn] >= 100:
		endgame()
	turn = (turn + 1) % 4
	Dice_Mover(turn)
	
	if player_or_ai[turn]:
		await get_tree().create_timer(1.0).timeout
		ai_turn()
	else:
		Dice_Run = 1
	
	$Dice_Drawed/Dice_Drawed.show()

func _move_player(player_index: int, steps: int) -> void:
	if not is_running:
		return
	
	var player_node = Player_Path[player_index]
	var curve = 0
	if one_or_two_map:
		curve = $oneboard/Path.get_curve()
	else:
		curve = $twoboard/Path.get_curve()
	
	var tween = create_tween()

	for i in range(steps):
		if PlayerPosition[player_index] >= 100:
			break
		PlayerPosition[player_index] += 1
		var point_index = PlayerPosition[player_index] - 1
		var next_pos = curve.get_point_position(point_index)
		var offset_pos = set_offset_for_pawns(next_pos, player_index)
		tween.tween_property(player_node, "position", offset_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	var current = PlayerPosition[player_index]
	if one_or_two_map:
		if current in one_Ladder_Location:
			PlayerPosition[player_index] = one_Ladder_Location[current]
		elif current in one_Snake_Location:
			PlayerPosition[player_index] = one_Snake_Location[current]
			$Snake.play()
	else:
		if current in two_Ladder_Location:
			PlayerPosition[player_index] = two_Ladder_Location[current]
		elif current in two_Snake_Location:
			PlayerPosition[player_index] = two_Snake_Location[current]
			$Snake.play()
	if one_or_two_map:
		if current in one_Ladder_Location or current in one_Snake_Location:
			var final_point = curve.get_point_position(PlayerPosition[player_index] - 1)
			var offset_final = set_offset_for_pawns(final_point, player_index)
			var jump_tween = create_tween()
			jump_tween.tween_property(player_node, "position", offset_final, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			await jump_tween.finished
	else:
		if current in two_Ladder_Location or current in two_Snake_Location:
			var final_point = curve.get_point_position(PlayerPosition[player_index] - 1)
			var offset_final = set_offset_for_pawns(final_point, player_index)
			var jump_tween = create_tween()
			jump_tween.tween_property(player_node, "position", offset_final, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			await jump_tween.finished
func Dice_Mover(player_index: int) -> void:
	if not is_running:
		return
	
	var pos = Dice_Position[player_index]
	$Dice_Drawed.position = pos
	$Dice_Animation.position = pos

func set_offset_for_pawns(pos: Vector2, player_index: int) -> Vector2:
	var offset_amount = 8
	match player_index:
		0:
			return pos + Vector2(-offset_amount, -offset_amount)
		1:
			return pos + Vector2(offset_amount, -offset_amount)
		2:
			return pos + Vector2(-offset_amount, offset_amount)
		3:
			return pos + Vector2(offset_amount, offset_amount)
		_:
			return pos

func one_player() -> void:
	player_or_ai = [false, true, true, true]

func two_player() -> void:
	player_or_ai = [false, false, true, true]

func three_player() -> void:
	player_or_ai = [false, false, false, true]

func four_player() -> void:
	player_or_ai = [false, false, false, false]

func go_back_to_startScreen():
	$endScreen.hide()
	$StartScreen.show()
	$Dice_Animation.hide()
	$Dice_Drawed.hide()
	Dice_Run = 0
	turn = 0
	
func endgame():
	$endScreen/player.text = Players[turn]
	$Dice_Drawed/Dice_Drawed.show()
	$endScreen.show()
	if one_or_two_map:
		$oneboard/Playing_Board.hide()
	else:
		$twoboard/Playing_Board.hide()
	is_running = false
	return

func save_game(player):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_var(player)
	file.close()

func load_game():
	var file = FileAccess.open(file_path, FileAccess.READ)
	if ResourceLoader.exists(file_path):
		Last_Won = file.get_var()
		file.close()
	else:
		Last_Won = "Nobody"
		

func _process(delta):
	if is_running:
		time_running += delta
	if int(time_running) != last_updated:
		last_updated = int(time_running)
		$Time.text = "Playing for " + str(int(time_running)) + " seconds" 
