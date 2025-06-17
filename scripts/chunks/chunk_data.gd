# res://scripts/level/ChunkData.gd
class_name ChunkData extends Resource

@export var chunk_coord: Vector2i = Vector2i.ZERO
@export var cardinal_direction: Vector3 = Vector3.FORWARD

# --- NEW PROPERTIES ---
# Booleans to track which walls have openings
@export var has_north_opening: bool = false
@export var has_south_opening: bool = false
@export var has_east_opening: bool = false
@export var has_west_opening: bool = false

# A data structure for the internal maze layout of this chunk.
# A 2D array is a good choice. 1 = Wall, 0 = Floor.
@export var tile_map_data: Array = [] 
