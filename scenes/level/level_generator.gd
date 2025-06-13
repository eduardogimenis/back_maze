extends Node3D

# A reference to the GridMap node in the scene
@onready var grid_map: GridMap = $GridMap

# Parameters for our level size
@export var width: int = 20
@export var height: int = 20

# This function will eventually create our maze.
# For now, it just creates a solid floor.
func generate():
	# Find the integer ID for our floor tile in the MeshLibrary.
	# Tile names match the node names from our "TileSource" scene.
	var floor_tile_id = grid_map.mesh_library.find_item_by_name("Floor")

	# Loop through every cell in our defined width and height
	for x in range(width):
		for z in range(height):
			# Place a floor tile at the current (x, z) coordinate on layer 0 (the ground).
			grid_map.set_cell_item(Vector3i(x, 0, z), floor_tile_id)
