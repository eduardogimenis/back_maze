# res://scripts/level/MazeGenerator.gd
class_name MazeGenerator extends Resource

# --- Trail Customization ---
@export var min_trail_length: int = 5
@export var max_trail_length: int = 12

var width: int
var height: int

var world_data: Dictionary = {}
var start_chunk_coord: Vector2i
var end_chunk_coord: Vector2i

var _visited_chunks: Dictionary = {}


func generate_layout(maze_width: int, maze_height: int) -> Dictionary:
	self.width = maze_width
	self.height = maze_height
	world_data.clear()
	_visited_chunks.clear()

	start_chunk_coord = Vector2i(randi_range(0, width -1), randi_range(0, height-1))
	
	for x in range(width):
		for y in range(height):
			var coord = Vector2i(x, y)
			var chunk_data = ChunkData.new()
			chunk_data.chunk_coord = coord
			world_data[coord] = chunk_data
			
	_carve_trails_from(start_chunk_coord, Vector2i.ZERO) # Start with no initial direction
	
	return world_data


# This is a new algorithm that prioritizes straight lines.
func _carve_trails_from(current_coord: Vector2i, previous_direction: Vector2i):
	_visited_chunks[current_coord] = true
	end_chunk_coord = current_coord # The last visited chunk is always the end for now

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	directions.shuffle()

	# Try to continue in the same direction first
	if previous_direction != Vector2i.ZERO and directions.has(previous_direction):
		directions.erase(previous_direction)
		directions.insert(0, previous_direction)

	for direction in directions:
		var trail_length = randi_range(min_trail_length, max_trail_length)
		var current_pos_in_trail = current_coord
		
		var can_carve = true
		# Check if the entire potential trail is within bounds and unvisited
		for i in range(trail_length):
			var next_pos = current_pos_in_trail + direction * (i + 1)
			if not _is_valid(next_pos):
				can_carve = false
				break
		
		if can_carve:
			# If the path is clear, carve the whole trail
			var last_pos_in_trail = current_coord
			for i in range(trail_length):
				var next_pos = current_pos_in_trail + direction * (i + 1)
				_remove_walls_between(last_pos_in_trail, next_pos)
				_visited_chunks[next_pos] = true
				last_pos_in_trail = next_pos
			
			# After carving a trail, recursively start from its end
			_carve_trails_from(last_pos_in_trail, direction)


func _is_valid(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.x >= width or coord.y < 0 or coord.y >= height:
		return false # Out of bounds
	if _visited_chunks.has(coord):
		return false # Already part of another trail
	return true


func _remove_walls_between(coord_a: Vector2i, coord_b: Vector2i):
	var chunk_a = world_data[coord_a]
	var chunk_b = world_data[coord_b]
	
	var diff = coord_b - coord_a
	
	if diff == Vector2i(0, -1): # B is North of A
		chunk_a.has_north_opening = true
		chunk_b.has_south_opening = true
	elif diff == Vector2i(0, 1): # B is South of A
		chunk_a.has_south_opening = true
		chunk_b.has_north_opening = true
	elif diff == Vector2i(1, 0): # B is East of A
		chunk_a.has_east_opening = true
		chunk_b.has_west_opening = true
	elif diff == Vector2i(-1, 0): # B is West of A
		chunk_a.has_west_opening = true
		chunk_b.has_east_opening = true
