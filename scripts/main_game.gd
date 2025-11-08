extends Node2D

var Dice_Run = 1
var Dice_Position = {
	0: Vector2(122, 939),
	1: Vector2(118, 52),
	2: Vector2(455, 52),
	3: Vector2(452, 937)
}
var Ladder_Location = {
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
var PlayerPosition = [0, 0, 0, 0]
var Dice_Face = 0
var turn = 0
var Player_Path = []
var square_positions = []

func _ready():
	$Dice_Animation.hide()
	Player_Path = [$Path/Yellow_Player, $Path/Blue_Player, $Path/Red_Player, $Path/Green_Player]
	Dice_Mover(turn)

func _process(_delta: float):
	pass

func _on_button_pressed():
	if Dice_Run != 0:
		$Dice_Drawed.hide()
		$Dice_Animation.show()
		$Dice_Animation.play("dice_draw")
		Dice_Run = 0

func _on_dice_animation_finished():
	randomize()
	Dice_Face = randi_range(0, 5)
	$Dice_Animation.hide()
	$Dice_Drawed.show()
	$Dice_Drawed.set_frame(Dice_Face)
	var dice_value = Dice_Face + 1
	$Dice_Drawed/Button.hide()
	if PlayerPosition[turn] == 0:
		if dice_value == 1:
			var Path_Point = $Path.get_curve().get_point_position(0)
			Player_Path[turn].position = Path_Point
			PlayerPosition[turn] += dice_value
	else:
		PlayerPosition[turn] += dice_value
		await Player_Mover(turn)
	await get_tree().create_timer(0.5).timeout
	turn = (turn + 1) % 4
	Dice_Mover(turn)
	$Dice_Drawed/Button.show()
	Dice_Run = 1

func Player_Mover(player_index):
	var current_position = PlayerPosition[player_index]
	if current_position in Ladder_Location:
		PlayerPosition[player_index] = Ladder_Location[current_position]
	var final_position = PlayerPosition[player_index]
	var Path_Point = $Path.get_curve().get_point_position(final_position - 1)
	var player_node = Player_Path[player_index]
	var tween := create_tween()
	tween.tween_property(player_node, "position", Path_Point, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func Dice_Mover(Player_Index):
	var pos = Dice_Position[Player_Index]
	$Dice_Drawed.position = pos
	$Dice_Animation.position = pos
