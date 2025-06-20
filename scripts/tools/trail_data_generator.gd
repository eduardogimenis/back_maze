# res://scripts/tools/TrailDataGenerator.gd
# Attach this script to the root node of a trail scene to generate its data.
@tool
extends Node3D

# --- Configuration ---
@export var resource_path: String = ""
@export var process_scene_now: bool = false:
	set(value):
		if value:
			_generate_trail_data()
			# Uncheck the box so it acts like a button
			process_scene_now = false 

func _ready():
	# Automatically suggest a resource path based on the scene's file path.
	if get_tree() and get_tree().edited_scene_root == self:
		if self.scene_file_path and resource_path == "":
			# --- FIX ---
			# Replaced `get_scene().name` with `scene_file_path.get_basename()`
			# to correctly get the name of the scene file.
			resource_path = self.scene_file_path.get_base_dir().path_join(self.scene_file_path.get_basename() + ".tres")

func _generate_trail_data():
	# Ensure this code only runs in the editor and on a scene with a valid file path.
	if not Engine.is_editor_hint() or not self.scene_file_path:
		# --- FIX ---
		# Replaced `print_error()` with the correct Godot function `push_error()`.
		push_error("This tool can only be run from a saved scene in the Godot editor.")
		return

	print("--- Starting Trail Data Generation for: ", self.name, " ---")

	# Load the existing resource or create a new one.
	var trail_data: TrailData
	if ResourceLoader.exists(resource_path):
		trail_data = load(resource_path)
		print("Loaded existing TrailData resource from: ", resource_path)
	else:
		trail_data = TrailData.new()
		print("Creating new TrailData resource.")

	# Assign this scene to the data resource.
	trail_data.scene = load(self.scene_file_path)

	# Find all markers and update the connectors dictionary.
	trail_data.connectors = _find_connectors()

	# Save the resource to the specified path.
	var result = ResourceSaver.save(trail_data, resource_path)
	if result == OK:
		print(">>> Successfully saved TrailData to: ", resource_path)
	else:
		push_error("Failed to save TrailData resource!")

func _find_connectors() -> Dictionary:
	var found_connectors = {}
	_find_markers_recursively(self, found_connectors)
	return found_connectors

# Recursively searches the scene tree for Marker3D nodes.
func _find_markers_recursively(node: Node, connectors_dict: Dictionary):
	if node is Marker3D:
		var marker_name = node.name
		var marker_transform = node.transform
		var direction_vector = -marker_transform.basis.z.normalized() # The "forward" blue arrow
		var direction_name = _get_direction_name(direction_vector)
		
		print("Found Connector: '", marker_name, "' | Direction: ", direction_name, " (", direction_vector, ")")
		
		connectors_dict[marker_name] = {
			"transform": marker_transform,
			"direction": direction_name
		}

	for child in node.get_children():
		_find_markers_recursively(child, connectors_dict)

# Analyzes a vector to determine its cardinal direction name.
func _get_direction_name(direction: Vector3) -> String:
	if direction.is_equal_approx(Vector3.FORWARD): return "North"
	if direction.is_equal_approx(Vector3.BACK): return "South"
	if direction.is_equal_approx(Vector3.LEFT): return "West"
	if direction.is_equal_approx(Vector3.RIGHT): return "East"
	
	# Handle cases where the marker is not perfectly aligned
	push_warning("Marker is not aligned to a cardinal direction! " + str(direction))
	
	var max_dot = -INF
	var best_match = "Unknown"
	
	if direction.dot(Vector3.FORWARD) > max_dot:
		max_dot = direction.dot(Vector3.FORWARD)
		best_match = "North"
	if direction.dot(Vector3.BACK) > max_dot:
		max_dot = direction.dot(Vector3.BACK)
		best_match = "South"
	if direction.dot(Vector3.LEFT) > max_dot:
		max_dot = direction.dot(Vector3.LEFT)
		best_match = "West"
	if direction.dot(Vector3.RIGHT) > max_dot:
		max_dot = direction.dot(Vector3.RIGHT)
		best_match = "East"
		
	return best_match
