# File creator: A.P.
extends Node2D

@export var curse_controller : Node

var currentDrawing : CurseDrawing
var currentElemIndex: int
var currentElement : Node

var slider_started : bool = false
var slider_length_completed : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_input(false)

func _physics_process(delta):
	if slider_started:
		assert(currentElement is CurseSlider)
		var currentSlider : CurseSlider = currentElement
		
		# Calculate amount of slider completed
		var new_slider_length_completed = currentSlider.curve.get_closest_offset(get_global_mouse_position())
		if slider_length_completed < new_slider_length_completed:
			slider_length_completed = new_slider_length_completed

# If one of the buttons on screen is not pressed, the input will come here
func _unhandled_input(event):
	if event.is_action_pressed("curse_drawing_press"):
			# If in this function, the player failed to hit or start the element
			
			if currentElement is CurseButton:
				var currentButton : CurseButton = currentElement
				
				print("Failed button")
			elif currentElement is CurseSlider:
				var currentSlider : CurseSlider = currentElement
				print("Failed slider completely")
			
				reset_slider(currentSlider)
			set_next_element()

func _input(event):
	if event.is_action_released("curse_drawing_press") and slider_started:
			assert(currentElement is CurseSlider)
			slider_started = false
			
			var currentSlider : CurseSlider = currentElement
			
			if currentSlider.mouse_exited.is_connected(_slider_exited_early):
				currentSlider.mouse_exited.disconnect(_slider_exited_early)
			
			if currentSlider.end_zone.is_hovered():
				print("Slider success")
			else:
				print("Failed slider and completed " + String.num_int64(slider_length_completed / currentSlider.curve.get_baked_length() * 100) + "% of the slider")
			
			reset_slider(currentSlider)
			set_next_element()

# Set the drawing map to the one for the given curse
func set_curse(curse: String):
	# Remove existing drawing scenes
	if get_child_count() > 0:
		for i in get_child_count():
			remove_child(get_child(i - 1))
	
	match curse:
		"fear":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_test.tscn").instantiate()
			add_child(currentDrawing)
		"tear":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_tear.tscn").instantiate()
			add_child(currentDrawing)
		"taste":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_test.tscn").instantiate()
			add_child(currentDrawing)
		_:
			push_error("Failed to set curse drawing for curse " + curse)
	
	# Reset the current element
	assert(currentDrawing.elements.size() != 0)
	currentElemIndex = 0
	currentElement = currentDrawing.elements[currentElemIndex]
	currentElement.visible = true
	
	if currentElement is CurseButton:
		var currentButton : CurseButton = currentElement
		if not (currentButton.curse_press.is_connected(_curse_pressed)):
			currentButton.curse_press.connect(_curse_pressed)
	if currentElement is CurseSlider:
		var currentSlider : CurseSlider = currentElement
		if not (currentSlider.start_pressed.is_connected(_slider_start_pressed)):
			currentSlider.start_pressed.connect(_slider_start_pressed)
		
		if not (currentSlider.end_pressed.is_connected(_slider_end_pressed)):
			currentSlider.end_pressed.connect(_slider_end_pressed)
	
	set_process_unhandled_input(true)

func _curse_pressed():
	print("Success")
	
	assert(currentElement is CurseButton)
	
	var currentButton : CurseButton = currentElement
	currentButton.texture_hover = currentButton.actual_texture_hover
	
	set_next_element()

func _slider_start_pressed():
	assert(currentElement is CurseSlider)
	
	slider_started = true
	print("Started slider")
	
	# Start checking for exiting the slider
	if currentElement is CurseSlider:
		var currentSlider : CurseSlider = currentElement
		
		if not currentSlider.mouse_exited.is_connected(_slider_exited_early):
				currentSlider.mouse_exited.connect(_slider_exited_early)

func _slider_end_pressed():
	print("Failed")
	set_next_element()

func _slider_exited_early():
	assert(currentElement is CurseSlider)
	slider_started = false
	
	var currentSlider : CurseSlider = currentElement
	
	# Disconnect since we should not be able to exit again
	assert(currentSlider.mouse_exited.is_connected(_slider_exited_early))
	currentSlider.mouse_exited.disconnect(_slider_exited_early)
	
	print("Failed slider and completed " + String.num_int64(slider_length_completed / currentSlider.curve.get_baked_length() * 100) + "% of the slider")
	
	reset_slider(currentSlider)
	set_next_element()

func set_next_element():
	currentElement.visible = false
	
	currentElemIndex += 1
	
	# All elements pressed so end the game and return from this function
	if currentElemIndex >= currentDrawing.elements.size():
		set_process_unhandled_input(false)
		visible = false
		
		curse_controller.curse_state = curse_controller.CurseState.ACTIVE
		return
	
	currentElement = currentDrawing.elements[currentElemIndex]
	currentElement.visible = true
	
	if currentElement is CurseButton:
		var currentButton : CurseButton = currentElement
		if not (currentButton.curse_press.is_connected(_curse_pressed)):
			currentButton.curse_press.connect(_curse_pressed)
	if currentElement is CurseSlider:
		var currentSlider : CurseSlider = currentElement
		if not (currentSlider.start_pressed.is_connected(_slider_start_pressed)):
			currentSlider.start_pressed.connect(_slider_start_pressed)
		
		if not (currentSlider.end_pressed.is_connected(_slider_end_pressed)):
			currentSlider.end_pressed.connect(_slider_end_pressed)

func reset_slider(currentSlider : CurseSlider):
	slider_length_completed = 0
	currentSlider.start_zone.texture_normal = currentSlider.actual_texture_normal
	currentSlider.start_zone.texture_hover = currentSlider.actual_texture_hover
