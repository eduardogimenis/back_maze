# res://resources/trail_data.gd
class_name TrailData extends Resource

# The scene file for this trail piece.
@export var scene: PackedScene

# --- Connection Points ---
# A Dictionary defining the entry and exit points.
# The key is the name of the Marker3D in the scene (e.g., "entry", "exit_A").
# The value is the Transform3D of that Marker3D relative to the scene's origin.
# We will create a tool to auto-populate this later.
@export var connectors: Dictionary # e.g., {"entry_north": Transform3D(...), "exit_east": Transform3D(...)}

# --- Metadata for the Assembler ---
# Tags to categorize this piece for filtering.
@export var tags: Array[String] = [] # e.g., ["corridor", "t-junction", "dead-end"]

# How likely this piece is to be chosen. Higher numbers are more common.
@export var selection_weight: float = 1.0

# An approximate measure of the trail's length or size.
@export var complexity: int = 1
