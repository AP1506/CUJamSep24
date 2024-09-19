# File creator: A.P.
extends Node2D

@export var curse_controller : Node

var currentDrawing : CurseDrawing
var currentElemIndex: int
var currentElement : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_input(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.is_action("curse_drawing_press"):
			set_next_element()
			
			if currentElement is CurseButton:
				var currentButton : CurseButton = currentElement
				
				print("Failed")

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
		currentButton.curse_press.connect(_curse_pressed)
	
	set_process_unhandled_input(true)

func _curse_pressed():
	print("Success")
	set_next_element()

func set_next_element():
	currentElement.visible = false
	currentElemIndex += 1
	
	if currentElemIndex >= currentDrawing.elements.size():
		set_process_unhandled_input(false)
		visible = false
		
		curse_controller.set_process_unhandled_key_input(true)
		curse_controller.set_process(true)
		return
		# End the game and return from this function
	
	currentElement = currentDrawing.elements[currentElemIndex]
	currentElement.visible = true
	
	if currentElement is CurseButton:
		var currentButton : CurseButton = currentElement
		currentButton.curse_press.connect(_curse_pressed)
