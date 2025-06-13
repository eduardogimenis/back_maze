# res://scripts/camera/CameraRig.gd
extends Node3D

var target: Node3D
@export var follow_speed: float = 5.0

# --- NEW VARIABLES FOR ROTATION ---
# How quickly the camera rotates to its new angle.
@export var rotation_speed: float = 2.0
# The target rotation we want to smoothly turn towards.
var target_y_rotation_deg: float = 0.0

func _ready():
	target = get_tree().get_first_node_in_group("player")

# --- NEW FUNCTION ---
# This function is what the signal from the LevelManager will call.
func set_cardinal_direction(direction: Vector3):
	# We use atan2 to convert the direction vector (like North, West)
	# into an angle in radians, then convert it to degrees.
	target_y_rotation_deg = rad_to_deg(atan2(direction.x, direction.z))

func _process(delta: float):
	if is_instance_valid(target):
		# Position follow logic remains the same
		global_position = global_position.lerp(target.global_position, delta * follow_speed)
		
		# --- NEW ROTATION LOGIC ---
		# Get the current rotation in degrees.
		var current_y_rot = rad_to_deg(self.rotation.y)
		# Smoothly interpolate from the current angle to the target angle.
		# lerp_angle is essential for correctly handling wrapping (e.g., from 350deg to 10deg).
		var new_y_rot = lerp_angle(deg_to_rad(current_y_rot), deg_to_rad(target_y_rotation_deg), delta * rotation_speed)
		# Apply the new rotation.
		self.rotation.y = new_y_rot
