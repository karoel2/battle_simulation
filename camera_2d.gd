extends Camera2D

# Sensitivity of camera movement (adjust to your preference)
var sensitivity = 1.0
var dragging = false
var previous_mouse_position = Vector2.ZERO
var zoom_factor = 1.0  # Default zoom level

func _ready():
	# Ensure the mouse is captured for camera movement
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Detect if mouse is dragging
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			previous_mouse_position = event.position

func _process(delta):
	if dragging:
		# Get current mouse position
		var current_mouse_position = get_viewport().get_mouse_position()
		
		# Calculate the offset of the mouse movement
		var mouse_movement = current_mouse_position - previous_mouse_position
		
		# Move the camera based on the mouse movement and sensitivity
		position -= mouse_movement * sensitivity
		
		# Update previous mouse position
		previous_mouse_position = current_mouse_position
# Check if the zoom_in or zoom_out action is pressed
	if Input.is_action_just_pressed("zoom_in"):
		zoom_factor += 0.1  # Zoom in (reduce zoom factor)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_factor -= 0.1  # Zoom out (increase zoom factor)
	zoom_factor = clamp(zoom_factor, 0.1, 2.0)
	self.zoom = Vector2(zoom_factor, zoom_factor)
