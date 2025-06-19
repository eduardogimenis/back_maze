# res://scenes/ui/MainUI.gd
extends Control

@onready var compass_label: Label = $CanvasLayer/MarginContainer/MainColumns/LeftColumn/CompassPanel/VBoxContainer/Label2
@onready var stats_label: Label = $CanvasLayer/MarginContainer/MainColumns/LeftColumn/StatsPanel/Label
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.hide()
	get_tree().paused = false
	
	GameState.player_direction_changed.connect(on_player_direction_changed)
	# On startup, make sure the UI has the correct initial values.
	_update_ui_elements()

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		canvas_layer.visible = not canvas_layer.visible
		get_tree().paused = canvas_layer.visible
		
		if canvas_layer.visible:
			_update_ui_elements()

func _update_ui_elements():
	# Now this function correctly calls both update functions.
	_update_compass()
	_update_stats()

# This signal callback now just calls the dedicated update function.
func on_player_direction_changed(_new_direction: Vector3):
	_update_compass()

# --- NEW ---
# A dedicated function to update the compass label.
func _update_compass():
	if not is_instance_valid(compass_label): return

	var player_direction = GameState.player_input_direction
	var direction_text = "Unknown"
	if player_direction.is_equal_approx(Vector3.FORWARD): direction_text = "NORTH"
	elif player_direction.is_equal_approx(Vector3.BACK): direction_text = "SOUTH"
	elif player_direction.is_equal_approx(Vector3.LEFT): direction_text = "WEST"
	elif player_direction.is_equal_approx(Vector3.RIGHT): direction_text = "EAST"
	
	compass_label.text = "Facing: %s" % direction_text

# This function formats and displays the time played.
func _update_stats():
	if not is_instance_valid(stats_label): return

	var total_seconds = GameState.time_played_in_seconds
	
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	var time_string = "Time: %02d minutes & %02d seconds" % [minutes, seconds]
	
	stats_label.text = time_string


func _on_quit_button_pressed() -> void:
	get_tree().quit()
