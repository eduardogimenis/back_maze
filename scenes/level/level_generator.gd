# res://scripts/level/LevelManager.gd
extends Node3D

# --- NEW, MORE DESCRIPTIVE SIGNAL ---
# Emits the type of chunk entered and the chunk's data.
# Chunk types will be an Enum: TRAIL, CORNER, DECISION_POINT, DEAD_END.
signal player_entered_chunk(chunk_type: int, chunk_data: ChunkData)

enum ChunkType { TRAIL, CORNER, DECISION_POINT, DEAD_END }

@onready var grid_map: GridMap = $GridMap
@export var player: CharacterBody3D

var maze_generator: MazeGenerator = MazeGenerator.new()

const CHUNK_SIZE = 20
var world_data: Dictionary = {}
var current_chunk_coord: Vector2i = Vector2i(-999, -999)
var previous_chunk_coord: Vector2i = Vector2i(-999, -999)

func generate_world():
	# (This function remains mostly the same as the last version)
	grid_map.clear()
	world_data.clear()
	world_data = maze_generator.generate_layout(10, 10)

	for chunk_data in world_data.values():
		_draw_chunk_visuals(chunk_data)
		
	if is_instance_valid(player):
		var start_coord = maze_generator.start_chunk_coord
		player.global_position = Vector3(
			start_coord.x * CHUNK_SIZE + CHUNK_SIZE / 2.0,
			1.0,
			start_coord.y * CHUNK_SIZE + CHUNK_SIZE / 2.0
		)
		
	current_chunk_coord = Vector2i(-999,-999)
	previous_chunk_coord = Vector2i(-999,-999)
	
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
			previous_chunk_coord = current_chunk_coord
			current_chunk_coord = player_chunk_coord
			
			# Don't evaluate for the very first chunk on spawn
			if previous_chunk_coord.x != -999:
				_evaluate_chunk_type(world_data[current_chunk_coord])
			else: 
				# For the first chunk, treat it as a simple trail
				emit_signal("player_entered_chunk", ChunkType.TRAIL, world_data[current_chunk_coord])


func _evaluate_chunk_type(new_chunk: ChunkData):
	# 1. Get all openings for the new chunk
	var openings: Array[Vector3] = []
	if new_chunk.has_north_opening: openings.append(Vector3.FORWARD)
	if new_chunk.has_south_opening: openings.append(Vector3.BACK)
	if new_chunk.has_east_opening:  openings.append(Vector3.RIGHT)
	if new_chunk.has_west_opening:  openings.append(Vector3.LEFT)
	
	# 2. Determine the direction the player ENTERED from
	var entry_vector = previous_chunk_coord - new_chunk.chunk_coord
	var entry_direction = Vector3.ZERO
	if entry_vector == Vector2i(0, 1): entry_direction = Vector3.BACK
	elif entry_vector == Vector2i(0, -1): entry_direction = Vector3.FORWARD
	elif entry_vector == Vector2i(-1, 0): entry_direction = Vector3.LEFT
	elif entry_vector == Vector2i(1, 0): entry_direction = Vector3.RIGHT

	# 3. Create a list of all possible EXITS (remove the entrance)
	var exits = openings.duplicate()
	if entry_direction != Vector3.ZERO:
		exits.erase(entry_direction)

	# 4. Classify the chunk and emit the signal
	var chunk_type: int
	var new_forward: Vector3
	
	match exits.size():
		0:
			chunk_type = ChunkType.DEAD_END
			# The only way out is back the way we came
			new_forward = entry_direction
		1:
			# This is a corridor or a corner.
			new_forward = exits[0]
			# Check if it's a straight path or a turn
			if new_forward == -entry_direction:
				chunk_type = ChunkType.TRAIL
			else:
				chunk_type = ChunkType.CORNER
		_: # 2 or more exits
			chunk_type = ChunkType.DECISION_POINT
			# At a decision point, the "forward" direction is where we came from,
			# looking into the intersection. The CameraRig will handle the choices.
			new_forward = entry_direction

	new_chunk.cardinal_direction = new_forward
	emit_signal("player_entered_chunk", chunk_type, new_chunk)


func _draw_chunk_visuals(data: ChunkData):
	# This function remains exactly the same. No changes needed here.
	# Make sure you have "Floor" and "Wall" items in your MeshLibrary.
	# And remember to add collision to your "Wall" item eventually!
	var floor_tile = grid_map.mesh_library.find_item_by_name("Floor")
	var wall_tile = grid_map.mesh_library.find_item_by_name("Wall")
	if floor_tile == -1 or wall_tile == -1:
		push_error("MeshLibrary needs 'Floor' and 'Wall' items.")
		return
	var offset_x = data.chunk_coord.x * CHUNK_SIZE
	var offset_z = data.chunk_coord.y * CHUNK_SIZE
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
