# res://scripts/level/ChunkData.gd
class_name ChunkData extends Resource

# The coordinate of this chunk in the world grid (e.g., (0,0), (0,1), etc.)
@export var chunk_coord: Vector2i = Vector2i.ZERO

# The "up" direction for camera alignment.
# We'll use Godot's built-in direction constants.
@export var cardinal_direction: Vector3 = Vector3.FORWARD

# Booleans to track which walls have openings
@export var has_north_opening: bool = false
@export var has_south_opening: bool = false
@export var has_east_opening: bool = false
@export var has_west_opening: bool = false


# The primary, unchanging direction of the entire trail this chunk belongs to.
# This keeps the camera locked even when the path weaves.
@export var trail_direction: Vector3 = Vector3.ZERO
