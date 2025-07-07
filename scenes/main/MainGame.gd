# res://scripts/level/LevelAssembler.gd
# This script assembles a predefined sequence of trail scenes.
extends Node3D

# --- CONFIGURATION ---
# Create an array to hold the sequence of trail scenes you want to build.
# You will drag your .tscn files into this array in the Godot Inspector.
@export var trail_pieces: Array[PackedScene]

# The names of the Marker3D nodes inside your trail scenes.
const ENTRY_MARKER_NAME = "EntryPoint"
const EXIT_MARKER_NAME = "ExitPoint"


func _ready():
	# Automatically build the level when the game starts.
	build_level()


func build_level():
	# First, clear any previously generated level pieces.
	for child in get_children():
		child.queue_free()

	if trail_pieces.is_empty():
		push_warning("No trail pieces assigned to the LevelAssembler.")
		return

	# --- Place the first piece ---
	var first_piece_scene = trail_pieces[0]
	var current_instance = first_piece_scene.instantiate()
	add_child(current_instance)
	# The first piece is placed at the world origin.
	current_instance.global_transform = Transform3D.IDENTITY
	
	print("Placed starting piece: ", current_instance.name)

	# --- Place the rest of the pieces ---
	for i in range(1, trail_pieces.size()):
		var next_piece_scene = trail_pieces[i]
		
		# Find the exit point of the piece we just placed.
		var previous_exit_marker = current_instance.get_node_or_null(EXIT_MARKER_NAME)
		if not is_instance_valid(previous_exit_marker):
			push_error("Piece '", current_instance.name, "' is missing an exit marker named '", EXIT_MARKER_NAME, "'. Stopping generation.")
			return
			
		# Instantiate the new piece we want to add.
		var new_instance = next_piece_scene.instantiate()
		
		# Find the entry point of the new piece.
		var new_entry_marker = new_instance.get_node_or_null(ENTRY_MARKER_NAME)
		if not is_instance_valid(new_entry_marker):
			push_error("Piece '", new_instance.name, "' is missing an entry marker named '", ENTRY_MARKER_NAME, "'. Stopping generation.")
			new_instance.queue_free() # Clean up the failed instance
			return
			
		# --- THE CORE LOGIC ---
		# This is the transform math that connects the pieces.
		# It calculates the new piece's global transform so that its entry point
		# perfectly aligns with the previous piece's exit point.
		new_instance.global_transform = previous_exit_marker.global_transform * new_entry_marker.transform.inverse()
		
		# Add the new piece to the scene and update our reference for the next loop.
		add_child(new_instance)
		current_instance = new_instance
		print("Placed piece: ", current_instance.name)
