extends Node2D

var Dice_Run = 0
var Dice_Position = {
	0: Vector2(122, 939),
	1: Vector2(118, 52),
	2: Vector2(455, 52),
	3: Vector2(452, 937)
}
var Ladder_Location = {
	2: 18, 9: 28, 25: 47, 30: 50, 39: 41, 45: 57,
	51: 73, 65: 85, 79: 98, 89: 91
}
var Snake_Location = {
	99: 81, 97: 58, 95: 75, 93: 67, 90: 70, 66: 46,
	62: 60, 52: 33, 38: 17, 27: 5
}

var PlayerPosition = [0, 0, 0, 0]
var Dice_Face = 0
var turn = 0
var Player_Path = []
var square_positions = []

func _ready():
	$Dice_Animation.hide()
	Player_Path = [$Path/Yellow_Player, $Path/Blue_Player, $Path/Red_Player, $Path/Green_Player]

	$StartScreen.start.connect(start_game)
	$Dice_Drawed.hide()
	$Dice_Animation.hide()
	$Path.hide()
	$Playing_Board.hide()

func _on_dice_animation_finished():
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
			var Path_Point = $Path.get_curve().get_point_position(0)
			Player_Path[turn].position = set_offset_for_pawns(Path_Point, turn)

	else:
		await Player_Mover(turn, dice_value)

	await get_tree().create_timer(0.5).timeout
	turn = (turn + 1) % 4
	Dice_Mover(turn)
	$Dice_Drawed/Dice_Drawed.show()
	Dice_Run = 1

func Player_Mover(player_index, steps):
	var player_node = Player_Path[player_index]
	var curve = $Path.get_curve()
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
	if current in Ladder_Location:
		PlayerPosition[player_index] = Ladder_Location[current]
	elif current in Snake_Location:
		PlayerPosition[player_index] = Snake_Location[current]

	if current in Ladder_Location or current in Snake_Location:
		var final_point = curve.get_point_position(PlayerPosition[player_index] - 1)
		var offset_final = set_offset_for_pawns(final_point, player_index)
		var jump_tween := create_tween()
		jump_tween.tween_property(player_node, "position", offset_final, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await jump_tween.finished
	if PlayerPosition[player_index] >= 100:
		print("Player", player_index + 1, "wins!")

func Dice_Mover(player_index):
	var pos = Dice_Position[player_index]
	$Dice_Drawed.position = pos
	$Dice_Animation.position = pos

func start_game():
	$Dice_Drawed.show()
	$Path.show()
	$Playing_Board.show()
	$StartScreen.hide()
	Dice_Run = 1
	Dice_Mover(turn)

func _on_dice_drawed_pressed():
	if Dice_Run != 0:
		$Dice_Drawed.hide()
		$Dice_Animation.show()
		$Dice_Animation.play("dice_draw")
		Dice_Run = 0
		


func set_offset_for_pawns(pos: Vector2, player_index: int) -> Vector2:
	var offset_amount = 15
	match player_index:
		0:
			return pos + Vector2(-offset_amount, -offset_amount)
		1:
			return pos + Vector2(offset_amount, - offset_amount)
		2:
			return pos + Vector2(-offset_amount, offset_amount)
		3:
			return pos + Vector2(offset_amount, offset_amount)
		_:
			return pos
