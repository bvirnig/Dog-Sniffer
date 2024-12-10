extends Node

# Store the points and deposited points
var points: int = 0
var deposited_points: int = 0

# Reference to the AudioStreamPlayer for no points sound
@onready var no_points_sound = $nopoints

# This function can be used to reset the points and deposited points
func reset_points():
	points = 0
	deposited_points = 0

# This function will handle depositing 1 point
func deposit_points():
	if points > 0:
		points -= 1  # Deduct 1 point from the regular points
		deposited_points += 1  # Add 1 point to the deposited points
		print("Deposited 1 point. Regular Points: %d, Deposited Points: %d" % [points, deposited_points])
	else:
		print("No points to deposit!")  # If there are no points to deposit
		if no_points_sound:  # Ensure the AudioStreamPlayer is valid
			no_points_sound.play()  # Play the no points sound
