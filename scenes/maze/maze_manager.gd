# res://scripts/level/LevelManager.gd
extends Node3D

# --- NEW, SIMPLIFIED SIGNAL ---
# Emits the new cardinal direction only when the player enters a new trail.
signal trail_direction_changed(new_direction: Vector3)

@onready var grid_map: GridMap = $GridMap
@export var player: CharacterBody3D

var maze_generator: MazeGenerator = MazeGenerator.new()

const CHUNK_SIZE = 20
var world_data: Dictionary = {}
var current_chunk_coord: Vector2i = Vector2i(-999, -999)

# Tracks the direction of the trail the player is currently on.
var current_trail_direction: Vector3 = Vector3.ZERO

func generate_world():
	grid_map.clear()
	world_data.clear()
	# Using a larger maze size makes the trails more apparent
	world_data = maze_generator.generate_layout(25, 25) 

	for chunk_data in world_data.values():
		_draw_chunk_visuals(chunk_data)
		
	if is_instance_valid(player):
		var start_coord = _find_start_position()
		if start_coord != Vector2i(-1, -1):
			player.global_position = Vector3(
				start_coord.x * CHUNK_SIZE + CHUNK_SIZE / 2.0,
				1.0,
				start_coord.y * CHUNK_SIZE + CHUNK_SIZE / 2.0
			)
		else:
			push_error("Maze Generator failed to create any paths.")
		
	current_chunk_coord = Vector2i(-999,-999)
	current_trail_direction = Vector3.ZERO
	
	# Wait a frame to ensure all nodes are ready before the first update.
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(player):
		update_player_position(player.global_position)

func update_player_position(player_pos: Vector3):
	var player_chunk_coord = Vector2i(
		floor(player_pos.x / CHUNK_SIZE),
		floor(player_pos.z / CHUNK_SIZE)
	)
	
	if player_chunk_coord != current_chunk_coord:
		if world_data.has(player_chunk_coord):
			current_chunk_coord = player_chunk_coord
			var new_chunk_data = world_data[current_chunk_coord]
			
			# --- NEW SIMPLIFIED LOGIC ---
			# Check if the chunk belongs to a trail and if that trail's direction
			# is different from the one we are currently following.
			if new_chunk_data.trail_direction != Vector3.ZERO and \
			   new_chunk_data.trail_direction != current_trail_direction:
				
				# We've entered a new trail. Update the direction and notify the camera.
				current_trail_direction = new_chunk_data.trail_direction
				emit_signal("trail_direction_changed", current_trail_direction)


# Helper function to find a valid starting point in the generated maze
func _find_start_position() -> Vector2i:
	for chunk in world_data.values():
		# The first chunk we find that has a trail direction is a good start
		if chunk.trail_direction != Vector3.ZERO:
			return chunk.chunk_coord
	return Vector2i(-1, -1) # Return an invalid coord if no path was found


func _draw_chunk_visuals(data: ChunkData):
	# We only draw chunks that are part of a generated path.
	if data.trail_direction == Vector3.ZERO:
		return

	var floor_tile = grid_map.mesh_library.find_item_by_name("Floor")
	var wall_tile = grid_map.mesh_library.find_item_by_name("Wall")
	if floor_tile == -1 or wall_tile == -1:
		push_error("MeshLibrary needs 'Floor' and 'Wall' items.")
		return

	var offset_x = data.chunk_coord.x * CHUNK_SIZE
	var offset_z = data.chunk_coord.y * CHUNK_SIZE
	
	# This simple logic draws a floor and walls based on openings.
	# A more advanced version could use the weave to create diagonal walls.
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var tile_pos = Vector3i(offset_x + x, 0, offset_z + z)
			var is_on_north_edge = (z == 0)
			var is_on_south_edge = (z == CHUNK_SIZE - 1)
			var is_on_west_edge = (x == 0)
			var is_on_east_edge = (x == CHUNK_SIZE - 1)
			var is_edge = is_on_north_edge or is_on_south_edge or is_on_west_edge or is_on_east_edge
			
			if is_edge:
				if (is_on_north_edge and data.has_north_opening) or \
				   (is_on_south_edge and data.has_south_opening) or \
				   (is_on_west_edge and data.has_west_opening) or \
				   (is_on_east_edge and data.has_east_opening):
					grid_map.set_cell_item(tile_pos, floor_tile)
				else:
					grid_map.set_cell_item(tile_pos, wall_tile, 0)
			else:
				grid_map.set_cell_item(tile_pos, floor_tile)
