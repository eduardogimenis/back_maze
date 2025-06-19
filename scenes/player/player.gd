# res://scripts/player/Player.gd
extends CharacterBody3D

@export var speed: float = 15.0

# Get the gravity value from the project settings to be consistent.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float):
	# --- GRAVITY ---
	# Apply gravity every frame if the player is not on the floor.
	# This will make the character fall and stay grounded.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- HORIZONTAL MOVEMENT ---
	# Check the global lock. If we can't move horizontally, just apply friction.
	if not GameState.player_can_move:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# Standard movement logic from before
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var forward = GameState.player_input_direction
		var right = forward.cross(Vector3.UP).normalized()
		
		var direction = (forward * input_dir.y + right * -input_dir.x).normalized()

		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			# Apply friction when not moving
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	# --- FINAL MOVE ---
	# This function applies the final velocity, which now includes both
	# the gravity calculation and your horizontal movement.
	move_and_slide()
