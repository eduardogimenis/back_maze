# res://scripts/main/game_state.gd
# This script MUST be set up as an Autoload Singleton named "GameState" in your project settings.
# Project -> Project Settings -> Autoload
extends Node

# The current "forward" direction for player input.
# Updated by the CameraRig whenever the camera snaps to a new orientation.
# --- FIX ---
# The default is set to BACK instead of FORWARD. Godot's input system treats "up"
# (like the W key) as a negative value. By starting with an inverted vector,
# the initial player movement will feel correct (W moves forward).
var player_input_direction: Vector3 = Vector3.BACK

# A flag to check if the player is currently at an intersection.
# When true, the Player script will prevent movement.
var is_at_decision_point: bool = false
