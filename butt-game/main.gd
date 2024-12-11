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

# Reference to the buzzer sound in the GameOver scene
@onready var game_buzzer = preload("res://sounds/buzzer-or-wrong-answer-20582.mp3")  # Reference to the game buzzer sound

# Preload the sound to play when the game starts
@onready var game_start_sound = $startsound  # Replace with your start sound file

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
	"res://sounds/sniff-[AudioTrimmer.com] (1).mp3",
	"res://sounds/sniff-[AudioTrimmer.com] (1).mp3",
	"res://sounds/sniff-[AudioTrimmer.com] (1).mp3",
	"res://sounds/sniff-[AudioTrimmer.com] (1).mp3",
	"res://sounds/sniff-[AudioTrimmer.com] (1).mp3"
]

var selected_color_index: int = 0  # Tracks the current color index

# Add dogfarting event timer
@onready var dogfarting_timer = $FartTimer  # Timer for random dogfarting event
@onready var fart_sound_player = $fartsound  # Reference to fart sound AudioStreamPlayer
var dogfarting_active: bool = false  # Flag for dogfarting event

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	color_timer.start()
	game_timer.start()  # Start the game timer
	_set_selected_color()
	_update_instruction_label()
	_update_score_label()

	# Play the sound when the game starts
	game_start_sound.play()  # Play the game start sound

	# Connect the timeout signal of the game timer
	game_timer.timeout.connect(_on_game_timer_timeout)

	# Start dogfarting event timer
	dogfarting_timer.start(randf_range(5, 10))  # Random dogfarting start time between 5 and 10 seconds
	dogfarting_timer.timeout.connect(_on_dogfarting_timeout)  # Connect timeout signal for dogfarting event
	
	# Check if the GameTimerLabel node is available
	if game_timer_label == null:
		print("Error: GameTimerLabel node is not found in the scene.")
	else:
		# Update the game timer label every frame
		set_process(true)

# Timer timeout for dogfarting event
func _on_dogfarting_timeout() -> void:
	# Randomly activate or deactivate the dogfarting event
	dogfarting_active = !dogfarting_active
	print("Dogfarting event " + ("activated!" if dogfarting_active else "deactivated!"))
	
	# Play fart sound when the event is activated
	if dogfarting_active:
		fart_sound_player.play()  # Play the fart sound

	# Reset timer for the next dogfarting event
	dogfarting_timer.start(randf_range(5, 10))  # Random next activation between 5 and 10 seconds


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
			# Handle points based on whether dogfarting is active
			if dogfarting_active:
				# Decrease points when dogfarting is active, but don't let points go below 0
				Gamedata.points = max(Gamedata.points - 1, 0)
				print("Dogfarting! Lost 1 point. Points: %d" % Gamedata.points)
			else:
				# Regular behavior, gain points for correct input
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
	# Stop fart sound immediately when color changes
	fart_sound_player.stop()  # Stop the fart sound if it's playing
	
	# Deactivate the fart event on color change
	dogfarting_active = false  # Stop the fart event when color changes
	
	# Randomize the wait_time of the color timer (either 5 or 10 seconds)
	color_timer.wait_time = 5 if randi() % 2 == 0 else 10  # Correct ternary operator syntax
	color_timer.start()  # Restart the timer with the new random wait_time
	selected_color_index = randi() % allowed_colors.size()
	_set_selected_color()
	_update_instruction_label()

	# Restart the fart event after color change (if needed)
	# Start a new farting event (we start the timer for next fart event immediately)
	dogfarting_timer.start(randf_range(5, 10))  # Random next farting time between 5 and 10 seconds

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
	
	# Play the game buzzer sound
	if game_over_instance:
		var buzzer_sound = game_over_instance.get_node("gamebuzzer")  # Get the buzzer sound node
		if buzzer_sound:
			buzzer_sound.play()  # Play the game buzzer sound
	
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
			get_tree().change_scene_to_file("res://splash.tscn")  # Replace with your splash scene
