# res://scripts/main/game_state.gd
extends Node

# The current "forward" direction for player input.
var player_input_direction: Vector3 = Vector3.FORWARD

# --- NEW ---
# A global switch to enable or disable player movement controls.
var player_can_move: bool = true

# This is no longer needed with the new trail generator.
var is_at_decision_point: bool = false
