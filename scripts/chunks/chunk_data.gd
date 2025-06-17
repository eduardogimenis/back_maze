class_name ChunkData extends Resource

# The coordinate of this chunk in the world grid (e.g., (0,0), (0,1), etc.)
@export var chunk_coord: Vector2i = Vector2i.ZERO

# The "up" direction for camera alignment.
# We'll use Godot's built-in direction constants.
# North = (0, 0, -1), South = (0, 0, 1), East = (1, 0, 0), West = (-1, 0, 0)
@export var cardinal_direction: Vector3 = Vector3.FORWARD # Defaults to North

# We can add more data later, like what kind of maze to generate inside,
# what enemies to spawn, etc.
