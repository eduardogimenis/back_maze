# res://scripts/main/Game.gd
extends Node3D

@onready var level_manager: Node3D = $LevelGenerator
@onready var player: CharacterBody3D = $Player
# --- NEW --- Add a reference to the camera rig
@onready var camera_rig: Node3D = $CameraRig

func _ready():
	# --- NEW --- Connect the signal from the manager to the camera's function.
	# Now, whenever the LevelManager emits "chunk_changed", it will automatically
	# call the "set_cardinal_direction" function on our camera rig.
	level_manager.chunk_changed.connect(camera_rig.set_cardinal_direction)

	# Generate the world
	level_manager.generate_world()
	
	# Place the player at the start
	player.global_position = Vector3(10, 1, 10) # Centered in the first chunk


# --- NEW FUNCTION ---
# We use _physics_process for player-related logic as it's synced with the physics engine.
func _physics_process(delta: float):
	# Every frame, tell the level manager where the player is.
	level_manager.update_player_position(player.global_position)
