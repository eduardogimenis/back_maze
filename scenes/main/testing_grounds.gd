# res://scripts/main/Game.gd or testing_grounds.gd
extends Node3D

@onready var level_manager: Node3D = $LevelGenerator
@onready var player: CharacterBody3D = $Player
@onready var camera_rig: Node3D = $CameraRig

func _ready():
	# Connect the signal from the manager to the camera's function.
	level_manager.chunk_changed.connect(camera_rig.set_cardinal_direction)

	# Generate the world
	level_manager.generate_world()
	
	# Place the player at the start
	player.global_position = Vector3(10, 1, 10)


func _physics_process(delta: float):
	# Every frame, tell the level manager where the player is.
	if is_instance_valid(level_manager):
		level_manager.update_player_position(player.global_position)
