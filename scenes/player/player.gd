
# res://scripts/player/Player.gd
# This script is responsible for player movement.
extends CharacterBody3D

@export var speed: float = 15.0

func _physics_process(delta: float):
	# If we are at a decision point, the player is locked in place.
	if GameState and GameState.is_at_decision_point:
		# Stop all movement instantly
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return # Exit the function early to prevent movement input

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var forward = GameState.player_input_direction
	var right = forward.cross(Vector3.UP).normalized()
	
	# --- FIX ---
	# The key change is here. Input.get_vector() returns -1 on the Y-axis for "ui_up" (W key).
	# By multiplying by -input_dir.y, we ensure that pressing 'W' results in a positive forward
	# impulse, making the controls intuitive regardless of the camera's direction.
	var direction = (forward * -input_dir.y + right * input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
