# res://scripts/tools/MeshLibGenerator.gd
# This script runs in the Godot editor to generate a MeshLibrary.
@tool
extends Node

# --- CONFIGURATION ---
@export_dir var source_folder: String
@export var output_path: String = "/Users/eduardodecastilhosgimenis/Documents/programming/Godot/back_maze/scenes/testing/meshlibs/maze_theme.meshlib"

# --- NEW, BETTER DEBUGGING FEATURE ---
@export var generate_debug_scene: bool = true

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
			
			var collected_data = { "meshes": [], "shapes": [] }
			_collect_data_recursively(instance, Transform3D.IDENTITY, collected_data)

			if not collected_data.meshes.is_empty():
				print("Processing '", item_name, "'...")
				mesh_lib.create_item(id_counter)
				mesh_lib.set_item_name(id_counter, item_name)
				
				# Create a single mesh from all collected visual meshes.
				var item_mesh = ArrayMesh.new()
				var surface_tool = SurfaceTool.new()
				surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				for mesh_info in collected_data.meshes:
					surface_tool.append_from(mesh_info.mesh, 0, mesh_info.transform)
				surface_tool.index()
				item_mesh = surface_tool.commit()
				mesh_lib.set_item_mesh(id_counter, item_mesh)
				
				if not collected_data.shapes.is_empty():
					print("  - Found and added ", collected_data.shapes.size(), " collision shape(s).")
					mesh_lib.set_item_shapes(id_counter, collected_data.shapes)
				else:
					print("  - WARNING: No collision shapes found for this item.")

				id_counter += 1
			
			instance.queue_free()
			file_name = dir.get_next()

	ResourceSaver.save(mesh_lib, output_path)
	print("Successfully generated MeshLibrary and saved to: ", output_path)
	
	# --- DEBUG SCENE GENERATION ---
	if generate_debug_scene:
		_create_debug_scene(mesh_lib)


# This recursive function correctly finds all meshes and collision shapes
# and calculates their final, global transforms within the scene.
func _collect_data_recursively(node, parent_transform: Transform3D, collected_data: Dictionary):
	# The node's global transform is its parent's transform multiplied by its own local transform.
	var current_transform = parent_transform * node.transform

	# We only care about MeshInstance3D and CollisionShape3D nodes.
	if node is MeshInstance3D and node.mesh:
		collected_data.meshes.append({ "mesh": node.mesh, "transform": current_transform })
	
	if node is CollisionShape3D and node.shape:
		collected_data.shapes.append({ "shape": node.shape, "transform": current_transform })

	# Recurse into children.
	for child in node.get_children():
		_collect_data_recursively(child, current_transform, collected_data)

# This function creates a test scene to visualize the generated MeshLibrary.
func _create_debug_scene(mesh_lib: MeshLibrary):
	print("Generating debug scene...")
	var scene = Node3D.new()
	var grid_map = GridMap.new()
	grid_map.mesh_library = mesh_lib
	scene.add_child(grid_map)
	
	# Place one of each item from the library into the GridMap.
	for i in range(mesh_lib.get_last_unused_item_id()):
		if mesh_lib.get_item_name(i): # Check if the item exists
			grid_map.set_cell_item(Vector3i(i, 0, 0), i)
			
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene)
	
	if result == OK:
		var scene_path = "/Users/eduardodecastilhosgimenis/Documents/programming/Godot/back_maze/scenes/testing/meshlibs/debug_gridmap.tscn"
		ResourceSaver.save(packed_scene, scene_path)
		print("Successfully saved debug scene to: ", scene_path)
	else:
		push_error("Failed to pack debug scene.")
	
	scene.queue_free() # Clean up the temporary scene node
