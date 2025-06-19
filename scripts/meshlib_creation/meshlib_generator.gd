# res://scripts/tools/MeshLibGenerator.gd
# This script runs in the Godot editor to generate a MeshLibrary.
@tool
extends Node

# --- CONFIGURATION ---
# The folder containing your .tscn files (e.g., "res://scenes/level_pieces/static/").
@export_dir var source_folder: String
# The path where you want to save the final .meshlib resource.
@export var output_path: String = "/Users/eduardodecastilhosgimenis/Documents/programming/Godot/back_maze/scenes/testing/meshlibs/maze_theme.meshlib"
# Click this checkbox in the Inspector to run the generation.
@export var generate_now: bool = false:
	set(value):
		if value:
			generate_library()

# --- GENERATION LOGIC ---
func generate_library():
	if not source_folder:
		push_error("Source Folder path is not set.")
		return

	print("Starting MeshLibrary generation...")
	var mesh_lib = MeshLibrary.new()
	var id_counter = 0

	var dir = DirAccess.open(source_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() or not file_name.ends_with(".tscn"):
				file_name = dir.get_next()
				continue

			var scene_path = source_folder.path_join(file_name)
			var scene = load(scene_path)
			var instance = scene.instantiate()
			var item_name = file_name.get_slice(".", 0)
			
			var collected_data = { "surfaces": [], "shapes": [] }
			_collect_data_recursively(instance, Transform3D.IDENTITY, collected_data)

			if not collected_data.surfaces.is_empty():
				print("Adding '", item_name, "' to library.")
				mesh_lib.create_item(id_counter)
				mesh_lib.set_item_name(id_counter, item_name)
				
				var surface_tool = SurfaceTool.new()
				surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				for surface_info in collected_data.surfaces:
					surface_tool.append_from(surface_info.mesh, 0, surface_info.transform)
				surface_tool.index()
				mesh_lib.set_item_mesh(id_counter, surface_tool.commit())
				
				if not collected_data.shapes.is_empty():
					print("  - Found ", collected_data.shapes.size(), " collision shapes.")
					mesh_lib.set_item_shapes(id_counter, collected_data.shapes)

				id_counter += 1
			
			instance.queue_free()
			file_name = dir.get_next()

	else:
		push_error("Could not open source folder: ", source_folder)
		return

	ResourceSaver.save(mesh_lib, output_path)
	print("Successfully generated MeshLibrary and saved to: ", output_path)


# --- FIX: RECURSIVE HELPER FUNCTION ---
# This function traverses the entire node tree of a scene instance and collects
# all mesh and collision data, applying the cumulative transforms correctly.
func _collect_data_recursively(node, parent_global_transform: Transform3D, collected_data: Dictionary):
	# The node's global transform is its parent's transform multiplied by its own local transform.
	var node_global_transform = parent_global_transform * node.transform

	# If the current node is a MeshInstance3D, add its mesh data.
	if node is MeshInstance3D and node.mesh is Mesh:
		collected_data.surfaces.append({ "mesh": node.mesh, "transform": node_global_transform })
	
	# If the current node is a CollisionShape3D, add its shape data.
	if node is CollisionShape3D and node.shape is Shape3D:
		collected_data.shapes.append({ "shape": node.shape, "transform": node_global_transform })

	# Recursively call this function for all of the node's children.
	for child in node.get_children():
		_collect_data_recursively(child, node_global_transform, collected_data)
