extends Node2D  # Keeping the main scene as Node2D

# Reference to various nodes
@onready var color_rect = $ColorRect
@onready var color_timer = $ColorTimer
@onready var instruction_label = $InstructionLabel
@onready var sound_player = $sniffsound
@onready var score_label = $ScoreLabel
@onready var game_timer = $GameTimer  # Reference to the GameTimer node
@onready var game_timer_label = $GameTimerLabel  # Reference to the GameTimerLabel node

# Preload GameOver scene and reference it
@onready var game_over_scene = preload("res://game_over.tscn")
var game_over_instance: Node = null  # Holds the instance of the GameOver scene

# Predefined list of allowed colors
var allowed_colors = [
	Color(0.5, 0.0, 1.0),  # Purple
	Color(1.0, 0.0, 1.0),  # Pink
	Color(1.0, 1.0, 0.0),  # Yellow
	Color(0.0, 1.0, 0.0),  # Green
	Color(0.0, 0.0, 1.0),  # Blue
]

# Corresponding key actions
var color_keys = ["1", "2", "3", "4", "5"]

# Sound effect paths
var sound_effects = [
	"res://sounds/sniff-purple.mp3",
	"res://sounds/sniff-pink.mp3",
	"res://sounds/sniff-yellow.mp3",
	"res://sounds/sniff-green.mp3",
	"res://sounds/sniff-blue.mp3"
]

var selected_color_index: int = 0  # Tracks the current color index

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	color_timer.start()
	game_timer.start()  # Start the game timer
	_set_selected_color()
	_update_instruction_label()
	_update_score_label()
	# Connect the timeout signal of the game timer
	game_timer.timeout.connect(_on_game_timer_timeout)

	# Check if the GameTimerLabel node is available
	if game_timer_label == null:
		print("Error: GameTimerLabel node is not found in the scene.")
	else:
		# Update the game timer label every frame
		set_process(true)

# Helper function to set the selected color
func _set_selected_color() -> void:
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		color_rect.color = allowed_colors[selected_color_index]
	else:
		print("Invalid color index!")

# Update the instruction label
func _update_instruction_label() -> void:
	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		instruction_label.text = "Press " + color_keys[selected_color_index] + " when " + _get_color_name(allowed_colors[selected_color_index]) + " is up!"
	else:
		instruction_label.text = "Invalid color selection!"

# Helper function to get the color name
func _get_color_name(color: Color) -> String:
	if color == allowed_colors[0]: return "Purple"
	elif color == allowed_colors[1]: return "Pink"
	elif color == allowed_colors[2]: return "Yellow"
	elif color == allowed_colors[3]: return "Green"
	elif color == allowed_colors[4]: return "Blue"
	return "Unknown"

# Helper function to update the score label
func _update_score_label() -> void:
	score_label.text = str(Gamedata.deposited_points)

# Check key presses every frame
func _process(delta: float) -> void:
	if game_timer_label != null:
		# Update the GameTimerLabel with the remaining time
		game_timer_label.text = str(int(game_timer.time_left))  # Cast time_left to an integer for display
	else:
		print("GameTimerLabel is null, cannot update the text.")

	if selected_color_index >= 0 and selected_color_index < allowed_colors.size():
		if Input.is_action_just_pressed(color_keys[selected_color_index]):
			sound_player.stream = load(sound_effects[selected_color_index])
			sound_player.play()
			Gamedata.points += 1
			print("Points: %d" % Gamedata.points)
	
	if Input.is_action_just_pressed("6"):
		Gamedata.deposit_points()
		print("Deposited Points: %d" % Gamedata.deposited_points)
		_update_score_label()

# Timer timeout for color change
func _on_color_timer_timeout() -> void:
	selected_color_index = randi() % allowed_colors.size()
	_set_selected_color()
	_update_instruction_label()

# Game timer timeout (signals the end of the game)
func _on_game_timer_timeout() -> void:
	color_timer.stop()  # Stop the color timer
	game_timer.stop()  # Stop the game timer
	instruction_label.text = "Game Over! Final Score: " + str(Gamedata.deposited_points)
	print("Game Over! Final Score: %d" % Gamedata.deposited_points)
	
	# Instance the GameOver scene and add it to the main scene
	if game_over_instance == null:
		game_over_instance = game_over_scene.instantiate()  # Create the GameOver scene instance
		add_child(game_over_instance)  # Add it to the scene tree
	
	# Update the GameOver labels with the final score
	var game_over_label = game_over_instance.get_node("GameOverLabel")
	var final_score_label = game_over_instance.get_node("FinalScoreLabel")
	if game_over_label != null:
		game_over_label.text = "Game Over!"
	if final_score_label != null:
		final_score_label.text = "Final Score: " + str(Gamedata.deposited_points)

# Handle mouse click to return to the splash page
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Check if we are in the GameOver screen and the mouse was clicked
		if game_over_instance:
			# Change to the splash scene using the correct method in Godot 4
			get_tree().change_scene_to_file("res://splash.tscn")  # Replace with your splash scene path
