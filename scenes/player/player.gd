extends CharacterBody3D

@export var speed: float = 5.0

# This variable will hold a reference to the main camera.
# @onready ensures the variable is assigned right before the _ready() function runs.
@onready var camera = get_viewport().get_camera_3d()

func _physics_process(delta: float):
	# Get the input direction from the keyboard (e.g., WASD or arrow keys)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Get the camera's transform basis (its local coordinate system).
	# We use .orthonormalized() to ensure it's a clean rotation matrix without scaling.
	var camera_basis = camera.get_transform().basis.orthonormalized()
	
	# Calculate the forward direction relative to the camera.
	# We ignore the y-component to keep movement on the horizontal plane.
	var forward = -camera_basis.z
	forward.y = 0
	
	# Calculate the right direction relative to the camera.
	var right = camera_basis.x
	right.y = 0
	
	# Calculate the final movement direction based on camera orientation and input.
	var direction = (-forward * input_dir.y + right * input_dir.x).normalized()

	# Apply velocity if there's movement input
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# If no input, slow the character to a stop.
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Apply the movement
	move_and_slide()
