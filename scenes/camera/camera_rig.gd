# res://scripts/camera/CameraRig.gd
# This is now a simple follow-camera with no automatic orientation snapping.
extends Node3D

var target: Node3D
@export var follow_speed: float = 8.0

func _ready():
	# Find the player node in the scene.
	target = get_tree().get_first_node_in_group("player")
	
	# Set a default starting direction for the player's controls.
	if GameState:
		GameState.player_input_direction = Vector3.FORWARD

func _process(delta: float):
	# The camera's only job is to smoothly follow the player's position.
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, delta * follow_speed)

# All signal connection functions like "on_trail_direction_changed" have been removed.
