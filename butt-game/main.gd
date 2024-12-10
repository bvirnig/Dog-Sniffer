extends Node2D

# Reference to the ColorRect, Timer, and Label nodes
@onready var color_rect = $ColorRect
@onready var color_timer = $ColorTimer  # Use the existing ColorTimer in the scene
@onready var instruction_label = $InstructionLabel  # Reference to the Label node
@onready var sound_player = $sniffsound  # Reference to the AudioStreamPlayer node

# Predefined list of allowed colors (updated to include a sixth color)
var allowed_colors = [
	Color(0.5, 0.0, 1.0),  # Purple (index 0)
	Color(1.0, 0.0, 1.0),  # Pink (index 1)
	Color(1.0, 1.0, 0.0),  # Yellow (index 2)
	Color(0.0, 1.0, 0.0),  # Green (index 3)
	Color(0.0, 0.0, 1.0),  # Blue (index 4)
]

# A list of corresponding key actions that match the new color order
var color_keys = [
	"1",  # Purple (1 key)
	"2",  # Pink (2 key)
	"3",  # Yellow (3 key)
	"4",  # Green (4 key)
	"5",  # Blue (5 key)
]

# Sound effect paths for keys 1 to 5
var sound_effects = [
	"res://sounds/sniff-[AudioTrimmer.com].mp3",  # Purple key sound
	"res://sounds/sniff-[AudioTrimmer.com].mp3",  # Pink key sound
	"res://sounds/sniff-[AudioTrimmer.com].mp3",  # Yellow key sound
	"res://sounds/sniff-[AudioTrimmer.com].mp3",  # Green key sound
	"res://sounds/sniff-[AudioTrimmer.com].mp3"   # Blue key sound
]

# Variable to track the current color index
var selected_color_index: int = 0

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Ensure the timer is active (set its wait time and auto start)
	color_timer.start()  # Start the timer
	_set_selected_color()  # Set the initial color
	_update_instruction_label()  # Update the instruction label with the first instruction

# Helper function to set the selected color based on the current color index
func _set_selected_color() -> void:
	# Ensure the selected color index is within bounds of the allowed_colors array
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		color_rect.color = allowed_colors[selected_color_index]
		print("Selected color: " + _get_color_name(allowed_colors[selected_color_index]))  # Debug message
	else:
		print("Invalid color index!")  # Error if the index is out of bounds

# Update the instruction label to show the correct key for the new color
func _update_instruction_label() -> void:
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		instruction_label.text = "Pres33333333333333333333s " + color_keys[selected_color_index] + " when " + _get_color_name(allowed_colors[selected_color_index]) + " is up!"
	else:
		instruction_label.text = "Invalid color selection!"

# Helper function to get the color name as a string (for the label)
func _get_color_name(color: Color) -> String:
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
			# Play the corresponding sound
			sound_player.stream = load(sound_effects[selected_color_index])  # Load the sound for the key pressed
			sound_player.play()  # Play the sound
			# Add points to GameData
			Gamedata.points += 1  # Increase points stored in the GameData singleton
			print("Points: %d" % Gamedata.points)  # Print the points to the debug console

	# Always check if the "6" key is pressed
	if Input.is_action_just_pressed("6"):
		Gamedata.deposit_points()  # Call the deposit function to transfer points
		print("Deposited Points: %d" % Gamedata.deposited_points)  # Print the deposited points

# Called when the timer reaches its timeout (this function is called periodically)
func _on_color_timer_timeout() -> void:
	# Randomly choose a new color index
	selected_color_index = randi() % allowed_colors.size()  # Generates a random index
	_set_selected_color()  # Update the color on the ColorRect
	_update_instruction_label()  # Update the instruction label with the correct key for the new color
