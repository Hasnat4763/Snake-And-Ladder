extends Node2D

var Dice_Run = 1
var Dice_Position = [122, 939, 118.0, 52.0, 455.0, 52.0, 452.0, 937.0]
var PlayerRun = [0 ,0 ,0 ,0]
var Dice_Face = 0
var turn = 1
var Player_Path = []



func _ready() -> void:
	$Dice_Animation.hide()
	Player_Path = [$Path/Blue_Path_Follower/player, $Path/Green_Path_Follower/player, $Path/Red_Path_Follower/player, $Path/Yellow_Path_Follower/player]



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
	if PlayerRun[turn]:
		pass
	elif Dice_Face == 1:
		var Path_Point = $Path.get_curve().get_point_position(0)
		
	else:
		Dice_Run = 1
		turn += 1
		if turn == 4 :
			turn = 0
