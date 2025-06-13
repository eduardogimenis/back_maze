extends Node3D

# A variable to hold a reference to the player node
var target: Node3D

# How quickly the camera catches up to the player. Lower values are smoother.
@export var follow_speed: float = 5.0

func _ready():
	# Find the player in the scene as soon as the camera is ready.
	# This is a safe way to find the node without hard-coding paths.
	target = get_tree().get_first_node_in_group("player")

func _process(delta: float):
	# Check if the target (player) actually exists before trying to follow it.
	# This prevents errors if you run the camera scene by itself.
	if is_instance_valid(target):
		# Smoothly interpolate the camera's position towards the target's position.
		# This creates a much nicer, less rigid follow effect.
		# Multiplying by 'delta' makes the movement frame-rate independent.
		global_position = global_position.lerp(target.global_position, delta * follow_speed)
