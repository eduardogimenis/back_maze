# res://scenes/ui/MainUI.gd
extends Control

# We will get references to the labels and containers we want to update later.
# The path has been updated to include the "CanvasLayer" node you added.
@onready var compass_label: Label = $CanvasLayer/MarginContainer/MainColumns/LeftColumn/CompassPanel/Label
# Add more @onready vars here for other UI elements as you need them.

func _ready():
	# This node should be able to receive input even when the game is paused.
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# --- FIX ---
	# Using call_deferred("hide") is a more reliable way to ensure the UI is hidden
	# at startup. It waits until the current frame's processing is complete before
	# hiding the node, which prevents race conditions during scene initialization.
	call_deferred("hide")
	get_tree().paused = false


func _unhandled_input(event: InputEvent):
	# Listen for the toggle key. "ui_cancel" is usually Tab and Escape by default.
	if Input.is_action_just_pressed("ui_cancel"):
		# Toggle the visibility of the UI.
		self.visible = not self.visible
		
		# Pause or unpause the game based on the UI's visibility.
		get_tree().paused = self.visible
		
		# If the UI is now visible, update its contents.
		if self.visible:
			_update_ui_elements()

# This function will be called each time the UI is opened.
# We will add more logic to it later to populate each section.
func _update_ui_elements():
	# --- 1. Update Compass ---
	_update_compass()
	
	# --- 2. Update Inventory ---
	# (We'll add _update_inventory() later)
	
	# --- 3. Update Mental Map ---
	# (We'll add _update_mental_map() later)

func _update_compass():
	# A check to make sure GameState is available before using it.
	if not Engine.has_singleton("GameState"): return

	# Get the player's current forward direction from the global state.
	var player_direction = GameState.player_input_direction
	
	# Convert the vector direction to a cardinal direction name.
	var direction_text = "Unknown"
	if player_direction.is_equal_approx(Vector3.FORWARD):
		direction_text = "NORTH"
	elif player_direction.is_equal_approx(Vector3.BACK):
		direction_text = "SOUTH"
	elif player_direction.is_equal_approx(Vector3.LEFT):
		direction_text = "WEST"
	elif player_direction.is_equal_approx(Vector3.RIGHT):
		direction_text = "EAST"
		
	# A check to ensure the label node is valid before we try to access it.
	if is_instance_valid(compass_label):
		compass_label.text = "Facing: %s" % direction_text
