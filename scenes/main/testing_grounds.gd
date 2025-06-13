extends Node3D

# References to the main nodes in our game
@onready var level_generator: Node3D = $LevelGenerator

# This function is called when the node enters the scene tree.
func _ready():
	# Tell the level generator to build the level.
	level_generator.generate()
