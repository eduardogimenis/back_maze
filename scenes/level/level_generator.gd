# res://scripts/level/LevelManager.gd
extends Node3D

# A signal that we will emit whenever the player enters a new chunk.
# It will pass along the data for that new chunk.
signal chunk_changed(chunk_data: ChunkData)

@onready var grid_map: GridMap = $GridMap

const CHUNK_SIZE = 20
var world_data: Dictionary = {}

# A variable to keep track of the chunk the player is currently in.
var current_chunk_coord: Vector2i = Vector2i(-999, -999) # Start with an invalid coord

# This is called by Game.gd to build the world
func generate_world():
	grid_map.clear()
	world_data.clear()
	_generate_world_layout()
	for chunk_data in world_data.values():
		_draw_chunk_visuals(chunk_data)

# --- NEW FUNCTION ---
# This function will be called every frame by Game.gd
func update_player_position(player_pos: Vector3):
	# Calculate which chunk the player's position corresponds to.
	var player_chunk_coord = Vector2i(
		floor(player_pos.x / CHUNK_SIZE),
		floor(player_pos.z / CHUNK_SIZE)
	)
	
	# If the calculated chunk is different from the one we have stored...
	if player_chunk_coord != current_chunk_coord:
		# ...and if that new chunk actually exists in our world data...
		if world_data.has(player_chunk_coord):
			# ...then we update our tracker and emit the signal!
			current_chunk_coord = player_chunk_coord
			emit_signal("chunk_changed", world_data[current_chunk_coord])


func _generate_world_layout():
	var chunk1 = ChunkData.new()
	chunk1.chunk_coord = Vector2i(0, 0)
	chunk1.cardinal_direction = Vector3.FORWARD # North
	world_data[chunk1.chunk_coord] = chunk1
	
	var chunk2 = ChunkData.new()
	chunk2.chunk_coord = Vector2i(0, 1)
	chunk2.cardinal_direction = Vector3.FORWARD # North
	world_data[chunk2.chunk_coord] = chunk2

	var chunk3 = ChunkData.new()
	chunk3.chunk_coord = Vector2i(-1, 1)
	chunk3.cardinal_direction = Vector3.LEFT # West
	world_data[chunk3.chunk_coord] = chunk3

func _draw_chunk_visuals(data: ChunkData):
	var floor_tile = grid_map.mesh_library.find_item_by_name("Floor")
	var offset_x = data.chunk_coord.x * CHUNK_SIZE
	var offset_z = data.chunk_coord.y * CHUNK_SIZE
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var tile_pos = Vector3i(offset_x + x, 0, offset_z + z)
			grid_map.set_cell_item(tile_pos, floor_tile)
