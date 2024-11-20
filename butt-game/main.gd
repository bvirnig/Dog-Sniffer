extends Node2D

# Reference to the ColorRect, Timer, and Label nodes
@onready var color_rect = $ColorRect
@onready var color_timer = $ColorTimer
@onready var instruction_label = $InstructionLabel  # Reference to the Label node

# Predefined list of allowed colors
var allowed_colors = [
	Color(1.0, 0.0, 1.0),  # Pink
	Color(0.0, 1.0, 0.0),  # Green
	Color(1.0, 1.0, 0.0),  # Yellow
	Color(0.5, 0.0, 1.0),  # Purple
	Color(0.0, 0.0, 1.0)   # Blue
]

# A list of corresponding key actions that match the colors
var color_keys = [
	"1",  # Pink (1 key)
	"2",  # Green (2 key)
	"3",  # Yellow (3 key)
	"4",  # Purple (4 key)
	"5"   # Blue (5 key)
]

# Variable to track the score
var points = 0

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Ensure the timer is active and set to repeat every 2 seconds
	color_timer.start(2)  # Start the timer with a 2-second interval
	# Set the initial color when the game starts
	color_rect.color = _get_random_color()
	_update_instruction_label()  # Update the label with the instruction when the game starts

# Helper function to generate a random color from the allowed list
func _get_random_color() -> Color:
	return allowed_colors[randi() % allowed_colors.size()]  # Randomly select a color from the list

# Called every time the timer times out (every 2 seconds)
func _on_color_timer_timeout() -> void:
	# Change the color of the ColorRect to a random color from the allowed colors
	color_rect.color = _get_random_color()
	_update_instruction_label()  # Update the instruction label when the color changes

# Update the instruction label to show the correct key
func _update_instruction_label() -> void:
	var color_index = allowed_colors.find(color_rect.color)
	if color_index != -1:
		# Set the label text to show the correct key to press
		instruction_label.text = "Press " + color_keys[color_index] + " when " + _get_color_name(allowed_colors[color_index]) + " is up!"
	
# Helper function to get the color name as a string (for the label)
func _get_color_name(color: Color) -> String:
	if color == allowed_colors[0]:
		return "Pink"
	elif color == allowed_colors[1]:
		return "Green"
	elif color == allowed_colors[2]:
		return "Yellow"
	elif color == allowed_colors[3]:
		return "Purple"
	elif color == allowed_colors[4]:
		return "Blue"
	return "Unknown"

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	# Find the index of the current color in allowed_colors
	var color_index = allowed_colors.find(color_rect.color)

	# If the color is found in the array (it should always be, since we're only using allowed_colors)
	if color_index != -1:
		# Check if the correct key is pressed based on the color
		if Input.is_action_just_pressed(color_keys[color_index]):
			points += 1  # Increase the points if the correct key is pressed for that color
			print("Points: %d" % points)  # Print the points to the debug console
