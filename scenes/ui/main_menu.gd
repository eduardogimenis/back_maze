extends Control

func _on_start_button_pressed():
	# This function changes the current scene to our main game scene.
	get_tree().change_scene_to_file("res://scenes/main/MainGame.tscn")

func _on_quit_button_pressed():
	# This function closes the game.
	get_tree().quit()
