# res://scripts/camera/CameraRig.gd
extends Node3D

var target: Node3D
@export var follow_speed: float = 8.0

# --- NEW ---
# Create an export variable to hold our instanced BlinkLayer scene.
# You MUST drag your BlinkLayer node from the scene tree onto this slot in the Inspector.
@export var blink_layer: CanvasLayer 

# We will get the children from the blink_layer instance.
var blink_animator: AnimationPlayer
var blink_sound: AudioStreamPlayer3D

func _ready():
	target = get_tree().get_first_node_in_group("player")
	
	# Get references to the nodes inside our instanced scene.
	if blink_layer:
		blink_animator = blink_layer.get_node("AnimationPlayer")
		blink_sound = blink_layer.get_node("AudioStreamPlayer3D")
	else:
		push_error("BlinkLayer scene not assigned to CameraRig script in the Inspector.")
	
	if GameState:
		GameState.player_input_direction = Vector3.FORWARD

# This async function now orchestrates the entire blink transition.
# It should be connected to the LevelManager's 'trail_direction_changed' signal.
func on_trail_direction_changed(new_direction: Vector3):
	# Check if the blink animator is ready before proceeding.
	if not is_instance_valid(blink_animator): return

	# 1. Immediately disable player controls and start the blink.
	GameState.player_can_move = false
	blink_animator.play("Blink")
	if is_instance_valid(blink_sound) and blink_sound.stream:
		blink_sound.play()

	# 2. Wait for the screen to become fully black (half the animation time).
	await get_tree().create_timer(0.075).timeout
	
	# 3. Snap the camera's direction while the screen is black.
	_snap_to_direction(new_direction)
	
	# 4. Wait for the blink animation to finish.
	await get_tree().create_timer(1.075).timeout

	# 5. Re-enable player controls.
	GameState.player_can_move = true


func _process(delta: float):
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, delta * follow_speed)

# Helper function to instantly rotate the camera and update the GameState.
func _snap_to_direction(direction: Vector3):
	self.rotation.y = atan2(direction.x, direction.z)
	if GameState:
		GameState.player_input_direction = direction
