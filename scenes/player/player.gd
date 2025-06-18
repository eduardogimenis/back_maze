# res://scripts/player/Player.gd
extends CharacterBody3D

@export var speed: float = 15.0

func _physics_process(delta: float):
	# --- NEW ---
	# Check the global lock. If we can't move, stop and do nothing else.
	if not GameState.player_can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Standard movement logic from before
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var forward = GameState.player_input_direction
	var right = forward.cross(Vector3.UP).normalized()
	
	var direction = (forward * input_dir.y + right * -input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
