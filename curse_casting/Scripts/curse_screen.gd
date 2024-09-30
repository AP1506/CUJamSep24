# File creator: A.P.
class_name CurseScreen extends Node2D

signal curse_casted(curse_name: String, accuracy: int)

@export var curse_controller : Node
@export var world : Node
@export var bg : Node
@export var ui : Node
@export var accuracy_label : Label

var currentDrawing : CurseDrawing
var currentElemIndex: int
var currentElement : Node

var slider_started : bool = false
var slider_length_completed : int = 0

var curse_name : String
var accuracy : int =  0 # The total points achieved by the player
var max_accuracy : int = 0 # The max points achievable

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
				# Each button is worth one point for accuracy
				max_accuracy += 1
				update_accuracy(float(accuracy) /float(max_accuracy)  * 100)
			elif currentElement is CurseSlider:
				var currentSlider : CurseSlider = currentElement
				print("Failed slider completely")

				# Each slider is worth 1 accuracy point for every 100 pixels in length, rounded up
				max_accuracy += int(currentSlider.curve.get_baked_length()) / 100 + 1
				update_accuracy(float(accuracy) /float(max_accuracy)  * 100)
			
				reset_slider(currentSlider)
			set_next_element()

func _input(event):
	if event.is_action_released("curse_drawing_press") and slider_started:
			assert(currentElement is CurseSlider)
			slider_started = false
			
			var currentSlider : CurseSlider = currentElement
			
			if currentSlider.mouse_exited.is_connected(_slider_exited_early):
				currentSlider.mouse_exited.disconnect(_slider_exited_early)
			
			# Each slider is worth 1 accuracy point for every 100 pixels in length, rounded up
			max_accuracy += int(currentSlider.curve.get_baked_length()) / 100 + 1
			
			if currentSlider.end_zone.is_hovered():
				print("Slider success")
				accuracy += int(currentSlider.curve.get_baked_length()) / 100 + 1
			else:
				print("Failed slider and completed " + String.num_int64(slider_length_completed / currentSlider.curve.get_baked_length() * 100) + "% of the slider")
				accuracy += int(slider_length_completed) / 100 + 1

			update_accuracy(float(accuracy) /float(max_accuracy)  * 100)
			reset_slider(currentSlider)
			set_next_element()

# Set the drawing map to the one for the given curse
func set_curse(curse: String):
	# Remove existing drawing scenes
	if get_child_count() > 0:
		for i in get_child_count():
			remove_child(get_child(i - 1))

	curse_name = curse
	accuracy = 0
	max_accuracy = 0

	# Set the accuracy label
	update_accuracy(100)

	match curse:
		"fear":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_test.tscn").instantiate()
			add_child(currentDrawing)
		"tear":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_tear.tscn").instantiate()
			add_child(currentDrawing)
		"swear":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_swear.tscn").instantiate()
			add_child(currentDrawing)
		"taste":
			currentDrawing = preload("res://curse_casting/curse_drawings/drawing_test.tscn").instantiate()
			add_child(currentDrawing)
		"ward":
			currentDrawing = preload("res://curse_casting/curse_drawings/fire/drawing_ward.tscn").instantiate()
			add_child(currentDrawing)
		"dread":
			currentDrawing = preload("res://curse_casting/curse_drawings/fire/drawing_dread.tscn").instantiate()
			add_child(currentDrawing)
		"drag":
			currentDrawing = preload("res://curse_casting/curse_drawings/ice/drawing_drag.tscn").instantiate()
			add_child(currentDrawing)
		"scarf":
			currentDrawing = preload("res://curse_casting/curse_drawings/ice/drawing_scarf.tscn").instantiate()
			add_child(currentDrawing)
		"axed":
			currentDrawing = preload("res://curse_casting/curse_drawings/earth/drawing_axed.tscn").instantiate()
			add_child(currentDrawing)
		"dwarf":
			currentDrawing = preload("res://curse_casting/curse_drawings/earth/drawing_dwarf.tscn").instantiate()
			add_child(currentDrawing)
		"east":
			currentDrawing = preload("res://curse_casting/curse_drawings/air/drawing_east.tscn").instantiate()
			add_child(currentDrawing)
		"feast":
			currentDrawing = preload("res://curse_casting/curse_drawings/air/drawing_feast.tscn").instantiate()
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

func make_visible(value):
	visible = value
	bg.visible = value
	ui.visible = value

func _curse_pressed():
	print("Success")
	
	assert(currentElement is CurseButton)
	
	var currentButton : CurseButton = currentElement
	currentButton.texture_hover = currentButton.actual_texture_hover
	
	# Each button is worth one point for accuracy
	max_accuracy += 1
	accuracy += 1
	update_accuracy(float(accuracy) /float(max_accuracy)  * 100)

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

	assert(currentElement is CurseSlider)

	# Each slider is worth 1 accuracy point for every 100 pixels in length, rounded up
	max_accuracy += int(currentElement.curve.get_baked_length()) / 100 + 1
	update_accuracy(float(accuracy) /float(max_accuracy)  * 100)

	set_next_element()

func _slider_exited_early():
	assert(currentElement is CurseSlider)
	slider_started = false
	
	var currentSlider : CurseSlider = currentElement
	
	# Disconnect since we should not be able to exit again
	assert(currentSlider.mouse_exited.is_connected(_slider_exited_early))
	currentSlider.mouse_exited.disconnect(_slider_exited_early)

	print("Failed slider and completed " + String.num_int64(slider_length_completed / currentSlider.curve.get_baked_length() * 100) + "% of the slider")
	#print("Max accuracy added is " + String.num_int64(int(currentElement.curve.get_baked_length()) / 100 + 1))
	#print("Accuracy added is " + String.num_int64(int(slider_length_completed) / 100))
	# Each slider is worth 1 accuracy point for every 100 pixels in length, rounded up
	max_accuracy += int(currentElement.curve.get_baked_length()) / 100 + 1
	accuracy += int(slider_length_completed) / 100 + 1

	update_accuracy(float(accuracy) / float(max_accuracy) * 100)

	reset_slider(currentSlider)
	set_next_element()

func set_next_element():
	currentElement.visible = false

	currentElemIndex += 1

	# All elements pressed so end the game and return from this function
	if currentElemIndex >= currentDrawing.elements.size():
		end_mini_game()
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

func update_accuracy(percent):
	accuracy_label.text = "ACCURACY: " + String.num_int64(percent) + "%"

func end_mini_game():
	set_process_unhandled_input(false)
	make_visible(false)

	# Turn on other processes
	curse_controller.curse_state = curse_controller.CurseState.ACTIVE
	world.process_mode = Node.PROCESS_MODE_INHERIT

	assert(curse_name)
	curse_casted.emit(curse_name, float(accuracy) / float(max_accuracy) * 100)

func reset_slider(currentSlider : CurseSlider):
	slider_length_completed = 0
	currentSlider.start_zone.texture_normal = currentSlider.actual_texture_normal
	currentSlider.start_zone.texture_hover = currentSlider.actual_texture_hover
