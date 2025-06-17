# res://scripts/player/Player.gd
extends CharacterBody3D

@export var speed: float = 5.0

# We no longer need a direct reference to the camera!
# @onready var camera = get_viewport().get_camera_3d()

func _physics_process(delta: float):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# --- NEW LOGIC ---
	# Get the official "forward" direction from our global GameState.
	var forward = GameState.player_input_direction
	# Calculate the "right" direction using a cross product.
	var right = - forward.cross(Vector3.UP).normalized()
	
	# The rest of the calculation remains the same.
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
