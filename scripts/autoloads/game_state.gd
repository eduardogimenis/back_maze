# res://scripts/autoloads/game_state.gd
# This script is an Autoload singleton named "GameState"
extends Node

signal player_direction_changed(new_direction: Vector3)

# --- NEW ---
# A variable to track the total time played in seconds.
var time_played_in_seconds: float = 0.0

var player_input_direction: Vector3 = Vector3.FORWARD:
	set(new_value):
		player_input_direction = new_value
		emit_signal("player_direction_changed", player_input_direction)

var player_can_move: bool = true
var is_at_decision_point: bool = false

# --- NEW ---
# The _process function runs every frame.
func _process(delta: float):
	# We only increment the timer if the game is NOT paused.
	if not get_tree().paused:
		time_played_in_seconds += delta
