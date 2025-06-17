# res://scripts/camera/CameraRig.gd
extends Node3D

var target: Node3D
@export var follow_speed: float = 5.0
@export var rotation_speed: float = 3.0
var target_y_rotation_rad: float = 0.0

func _ready():
	target = get_tree().get_first_node_in_group("player")

func set_cardinal_direction(data: ChunkData):
	var direction = data.cardinal_direction
	target_y_rotation_rad = atan2(direction.x, direction.z)
	
	# --- THIS IS THE NEW, CRITICAL LINE ---
	# Instantly update the global state for player controls.
	GameState.player_input_direction = direction


func _process(delta: float):
	if not is_instance_valid(target):
		return

	global_position = global_position.lerp(target.global_position, delta * follow_speed)
	var new_y_rot = lerp_angle(self.rotation.y, target_y_rotation_rad, delta * rotation_speed)
	self.rotation.y = new_y_rot
