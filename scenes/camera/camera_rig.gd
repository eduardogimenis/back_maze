# res://scripts/camera/CameraRig.gd
# This script is responsible for camera movement and orientation.
extends Node3D

# Use the LevelManager's enum so we can reference it directly.
const LevelManager = preload("/Users/eduardodecastilhosgimenis/Documents/programming/Godot/back_maze/scenes/level/level_generator.gd")

var target: Node3D
@export var follow_speed: float = 8.0 # A slightly faster follow feels more responsive

var decision_exits: Array[Vector3] = []
var current_forward_dir: Vector3 = Vector3.FORWARD


func _ready():
	target = get_tree().get_first_node_in_group("player")
	# Ensure the initial direction and state are set in the GameState
	if GameState:
		# We set the initial direction to what feels "forward" for the player at start.
		GameState.player_input_direction = Vector3.FORWARD
		GameState.is_at_decision_point = false


# This is the function connected to the LevelManager's signal.
func on_player_entered_chunk(chunk_type: int, chunk_data: ChunkData):
	# We are no longer at a decision point until proven otherwise.
	if GameState:
		GameState.is_at_decision_point = false
	decision_exits.clear()

	match chunk_type:
		LevelManager.ChunkType.TRAIL:
			pass

		LevelManager.ChunkType.CORNER:
			print("Camera: Snapping to CORNER")
			_snap_to_direction(chunk_data.cardinal_direction)

		LevelManager.ChunkType.DEAD_END:
			print("Camera: Snapping to DEAD_END")
			_snap_to_direction(chunk_data.cardinal_direction)

		LevelManager.ChunkType.DECISION_POINT:
			print("Camera: Arrived at DECISION_POINT")
			if GameState:
				GameState.is_at_decision_point = true
			
			var entry_direction = -chunk_data.cardinal_direction
			_snap_to_direction(entry_direction)
			_calculate_decision_exits(chunk_data, entry_direction)


func _process(delta: float):
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, delta * follow_speed)


func _unhandled_input(event: InputEvent):
	# If we're at a decision point, check for player input to change view.
	if not GameState or not GameState.is_at_decision_point:
		return

	var chosen_direction: Vector3 = Vector3.ZERO
	
	if event.is_action_pressed("ui_left"):
		for dir in decision_exits:
			if dir.is_equal_approx(current_forward_dir.rotated(Vector3.UP, -PI/2)):
				chosen_direction = dir
				break
				
	elif event.is_action_pressed("ui_right"):
		for dir in decision_exits:
			if dir.is_equal_approx(current_forward_dir.rotated(Vector3.UP, PI/2)):
				chosen_direction = dir
				break
	
	if chosen_direction != Vector3.ZERO:
		print("Player chose direction: ", chosen_direction)
		_snap_to_direction(chosen_direction)
		GameState.is_at_decision_point = false
		decision_exits.clear()


func _snap_to_direction(direction: Vector3):
	current_forward_dir = direction
	self.rotation.y = atan2(direction.x, direction.z)
	if GameState:
		GameState.player_input_direction = direction


func _calculate_decision_exits(chunk_data: ChunkData, entry_dir: Vector3):
	var all_openings: Array[Vector3] = []
	if chunk_data.has_north_opening: all_openings.append(Vector3.FORWARD)
	if chunk_data.has_south_opening: all_openings.append(Vector3.BACK)
	if chunk_data.has_east_opening: all_openings.append(Vector3.RIGHT)
	if chunk_data.has_west_opening: all_openings.append(Vector3.LEFT)
	
	for opening in all_openings:
		if not opening.is_equal_approx(-entry_dir):
			decision_exits.append(opening)
	
	print("Available exits: ", decision_exits)
