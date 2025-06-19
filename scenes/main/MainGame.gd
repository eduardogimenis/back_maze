# res://scripts/main/testing_grounds.gd
extends Node3D

@onready var level_manager: Node3D = $LevelGenerator
@onready var player: CharacterBody3D = $Player
@onready var camera_rig: Node3D = $CameraRig

func _ready():
	# --- FIX ---
	# Connect the correct signal ('trail_direction_changed') from the LevelManager
	# to the correct function ('on_trail_direction_changed') in the CameraRig.
	level_manager.trail_direction_changed.connect(camera_rig.on_trail_direction_changed)

	# Generate the world
	level_manager.generate_world()
	
	# Place the player at the start (this is overridden by generate_world, but good for testing)
	player.global_position = Vector3(10, 1, 10)


func _physics_process(delta: float):
	# Every frame, tell the level manager where the player is.
	if is_instance_valid(level_manager):
		level_manager.update_player_position(player.global_position)
