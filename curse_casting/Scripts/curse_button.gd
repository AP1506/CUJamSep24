# File Creator: A.P.

class_name CurseButton extends TextureButton

signal curse_press

# Store to switch back and forth
var actual_texture_hover

# Called when the node enters the scene tree for the first time.
func _ready():
	if texture_normal:
		# Get the image from the texture normal
		var image = texture_normal.get_image()
		# Create the BitMap
		var bitmap = BitMap.new()
		# Fill it from the image alpha
		bitmap.create_from_image_alpha(image)
		# Assign it to the mask
		texture_click_mask = bitmap
	
	# Store normal texture to switch back and forth
	actual_texture_hover = texture_hover

func _input(event):
	# Stop propagating the pressed input event for non mouse clicks
	if event is InputEventKey:
		if event.is_action_pressed("curse_drawing_press") && is_hovered():
			# Simulate mouse press
			texture_hover = texture_pressed
			get_viewport().set_input_as_handled()
	
	# Done on release so that the button pressed image shows
	if Input.is_action_just_released("curse_drawing_press") && is_hovered():
		curse_press.emit()
		get_viewport().set_input_as_handled()
