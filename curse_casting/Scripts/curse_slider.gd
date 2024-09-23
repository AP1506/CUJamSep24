class_name CurseSlider extends Path2D

signal mouse_exited
signal start_pressed
signal end_pressed

var mouse_hovered

# Theoretically set how many times you can get progressive points on the slider
@export var num_ticks : int

var actual_texture_normal
var actual_texture_hover

@onready var line2d = $Line2D
@onready var line2d2 = $Line2D2 # For debugging purposes
@onready var start_zone = $StartZone
@onready var end_zone = $EndZone

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create the visible curve
	line2d.points = curve.get_baked_points()
	
	# Set tick points 
	
	# Set bitmasks for zone buttons
	if start_zone.texture_normal:
		# Get the image from the texture normal
		var image = start_zone.texture_normal.get_image()
		# Create the BitMap
		var bitmap = BitMap.new()
		# Fill it from the image alpha
		bitmap.create_from_image_alpha(image)
		# Assign it to the mask
		start_zone.texture_click_mask = bitmap
	
	if end_zone.texture_normal:
		# Get the image from the texture normal
		var image = end_zone.texture_normal.get_image()
		# Create the BitMap
		var bitmap = BitMap.new()
		# Fill it from the image alpha
		bitmap.create_from_image_alpha(image)
		# Assign it to the mask
		end_zone.texture_click_mask = bitmap
	
	# Scale and place the buttons at start and end zones
	start_zone.scale = Vector2(line2d.width, line2d.width) / start_zone.size
	start_zone.position = line2d.points[0] - start_zone.size * start_zone.scale / 2
	end_zone.scale = Vector2(line2d.width, line2d.width) / start_zone.size
	end_zone.position = line2d.points[-1] - end_zone.size * end_zone.scale / 2
	
	start_zone.visible = true
	end_zone.visible = true
	
	# Save the start zone texture for later

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#print("Distance to curve ")
	var distance = (get_global_mouse_position() - curve.sample_baked(curve.get_closest_offset(get_global_mouse_position()))).length()
	#print(distance)
	#print(curve.get_closest_offset(get_global_mouse_position()))
	line2d2.points[0] = get_viewport().get_mouse_position()
	line2d2.points[1] = curve.sample_baked(curve.get_closest_offset(get_global_mouse_position()))
	
	if distance <= line2d.width / 2:
		mouse_hovered = true
	else:
		if mouse_hovered:
			mouse_exited.emit()
		mouse_hovered = false

func _input(event):
	# Don't propagate key events as if it were real button press
	if event is InputEventKey:
		if Input.is_action_just_pressed("curse_drawing_press") && start_zone.is_hovered():
			start_zone.texture_hover = start_zone.texture_pressed
			start_zone.texture_normal = start_zone.texture_pressed
			
			get_viewport().set_input_as_handled()

	if Input.is_action_just_pressed("curse_drawing_press") && start_zone.is_hovered():
		start_pressed.emit()
	
	if Input.is_action_just_pressed("curse_drawing_press") && end_zone.is_hovered():
		end_pressed.emit()

func _area_entered():
	print("Area entered")
