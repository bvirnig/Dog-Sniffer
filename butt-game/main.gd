extends Node2D

# Reference to the ColorRect, Timer, and Label nodes
@onready var color_rect = $ColorRect
@onready var color_timer = $ColorTimer
@onready var instruction_label = $InstructionLabel  # Reference to the Label node

# Exported variable to manually select the color from the Inspector
@export var selected_color_index: int = 0  # Default to purple (index 0)

# Predefined list of allowed colors (updated order)
var allowed_colors = [
	Color(0.5, 0.0, 1.0),  # Purple (index 0)
	Color(1.0, 0.0, 1.0),  # Pink (index 1)
	Color(1.0, 1.0, 0.0),  # Yellow (index 2)
	Color(0.0, 1.0, 0.0),  # Green (index 3)
	Color(0.0, 0.0, 1.0)   # Blue (index 4)
]

# A list of corresponding key actions that match the new color order
var color_keys = [
	"1",  # Purple (1 key)
	"2",  # Pink (2 key)
	"3",  # Yellow (3 key)
	"4",  # Green (4 key)
	"5"   # Blue (5 key)
]

# Variable to track the score
var points = 0

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Set the initial color based on the selected_color_index from the Inspector
	_set_selected_color()
	_update_instruction_label()  # Update the instruction label with the instruction when the game starts

# Helper function to set the selected color based on the exported variable
func _set_selected_color() -> void:
	# Ensure the selected color index is within bounds of the allowed_colors array
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		color_rect.color = allowed_colors[selected_color_index]
		print("Selected color: " + _get_color_name(allowed_colors[selected_color_index]))  # Debug message
	else:
		print("Invalid color index! Please set a valid index.")  # Error if the index is out of bounds

# Update the instruction label to show the correct key
func _update_instruction_label() -> void:
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		instruction_label.text = "Press " + color_keys[selected_color_index] + " when " + _get_color_name(allowed_colors[selected_color_index]) + " is up!"
	else:
		instruction_label.text = "Invalid color selection!"

# Helper function to get the color name as a string (for the label)
func _get_color_name(color: Color) -> String:
	# Adjusted to ensure the correct color names match the color
	if color == allowed_colors[0]:
		return "Purple"
	elif color == allowed_colors[1]:
		return "Pink"
	elif color == allowed_colors[2]:
		return "Yellow"
	elif color == allowed_colors[3]:
		return "Green"
	elif color == allowed_colors[4]:
		return "Blue"
	return "Unknown"

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	# Check if the correct key is pressed based on the current selected color
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		if Input.is_action_just_pressed(color_keys[selected_color_index]):
			points += 1  # Increase the points if the correct key is pressed for that color
			print("Points: %d" % points)  # Print the points to the debug console
