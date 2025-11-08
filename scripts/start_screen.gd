extends Node2D

signal start
signal oneplayer
signal twoplayer
signal threeplayer
signal fourplayer

func _on_start_button_pressed():
	start.emit()


func _on_one_player_toggled(toggled_on: bool):
	if toggled_on:
		oneplayer.emit()
	else:
		return

func _on_two_player_toggled(toggled_on: bool):
	if toggled_on:
		twoplayer.emit()
	else:
		return

func _on_three_player_toggled(toggled_on: bool) -> void:
	if toggled_on:
		threeplayer.emit()
	else:
		return

func _on_four_player_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fourplayer.emit()
	else:
		return
