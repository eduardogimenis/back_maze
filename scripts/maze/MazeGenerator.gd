# res://scripts/level/MazeGenerator.gd
class_name MazeGenerator extends Resource

# --- Customization ---
@export var min_trail_length: int = 8
@export var max_trail_length: int = 15
# The chance (from 0.0 to 1.0) that a trail will take a sideways step to create a curve.
@export var weave_chance: float = 0.4 

# --- Internal State ---
var width: int
var height: int
var world_data: Dictionary = {}
var _visited_chunks: Dictionary = {}

# --- Public API ---
func generate_layout(maze_width: int, maze_height: int) -> Dictionary:
	# 1. Reset state
	self.width = maze_width
	self.height = maze_height
	world_data.clear()
	_visited_chunks.clear()

	# 2. Create all chunk data containers
	for x in range(width):
		for y in range(height):
			var coord = Vector2i(x, y)
			var chunk_data = ChunkData.new()
			chunk_data.chunk_coord = coord
			world_data[coord] = chunk_data
	
	# 3. Start the generation process from a random point
	var start_coord = Vector2i(randi_range(0, width-1), randi_range(0, height-1))
	_visited_chunks[start_coord] = true
	_carve_from(start_coord)
	
	return world_data

# --- Core Algorithm ---
func _carve_from(start_coord: Vector2i):
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	directions.shuffle()

	# For every possible direction from the current point...
	for trail_dir_vector in directions:
		var current_pos = start_coord
		var trail_length = randi_range(min_trail_length, max_trail_length)

		# ...try to carve a new trail.
		for i in range(trail_length):
			# Get the main direction and the possible sideways directions
			var perpendicular_dirs = _get_perpendicular(trail_dir_vector)
			var possible_steps = [trail_dir_vector, trail_dir_vector, perpendicular_dirs[0], perpendicular_dirs[1]]
			
			# Add more weight to moving straight
			if randf() > weave_chance:
				possible_steps.append(trail_dir_vector)
				possible_steps.append(trail_dir_vector)
			
			possible_steps.shuffle()

			var moved = false
			for step_dir in possible_steps:
				var next_pos = current_pos + step_dir
				
				# Check if the next position is valid (in bounds and unvisited)
				if _is_valid(next_pos):
					_remove_walls_between(current_pos, next_pos)
					
					# --- THIS IS THE KEY ---
					# Stamp both chunks with the MAIN trail direction, not the step direction.
					var trail_forward_vector = _vector2i_to_vector3(trail_dir_vector)
					world_data[current_pos].trail_direction = trail_forward_vector
					world_data[next_pos].trail_direction = trail_forward_vector
					
					current_pos = next_pos
					_visited_chunks[current_pos] = true
					moved = true
					break # We've taken our step, break to the next segment of the trail
			
			if not moved:
				# If we couldn't move anywhere, this trail is blocked and must end.
				break
		
		# After a trail is finished (or blocked), try to carve new trails from its end point.
		if current_pos != start_coord:
			_carve_from(current_pos)


# --- Helper Functions ---
func _is_valid(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.x >= width or coord.y < 0 or coord.y >= height:
		return false
	if _visited_chunks.has(coord):
		return false
	return true

func _get_perpendicular(dir: Vector2i) -> Array[Vector2i]:
	if dir == Vector2i.UP or dir == Vector2i.DOWN:
		return [Vector2i.LEFT, Vector2i.RIGHT]
	else: # LEFT or RIGHT
		return [Vector2i.UP, Vector2i.DOWN]

func _vector2i_to_vector3(v2i: Vector2i) -> Vector3:
	if v2i == Vector2i.UP: return Vector3.FORWARD
	if v2i == Vector2i.DOWN: return Vector3.BACK
	if v2i == Vector2i.LEFT: return Vector3.LEFT
	if v2i == Vector2i.RIGHT: return Vector3.RIGHT
	return Vector3.ZERO

func _remove_walls_between(coord_a: Vector2i, coord_b: Vector2i):
	var diff = coord_b - coord_a
	if diff == Vector2i.UP: # B is North of A
		world_data[coord_a].has_north_opening = true
		world_data[coord_b].has_south_opening = true
	elif diff == Vector2i.DOWN: # B is South of A
		world_data[coord_a].has_south_opening = true
		world_data[coord_b].has_north_opening = true
	elif diff == Vector2i.RIGHT: # B is East of A
		world_data[coord_a].has_east_opening = true
		world_data[coord_b].has_west_opening = true
	elif diff == Vector2i.LEFT: # B is West of A
		world_data[coord_a].has_west_opening = true
		world_data[coord_b].has_east_opening = true
