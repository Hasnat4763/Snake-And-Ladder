extends Node2D
signal startScreen

func _on_goback_pressed() -> void:
	startScreen.emit()
