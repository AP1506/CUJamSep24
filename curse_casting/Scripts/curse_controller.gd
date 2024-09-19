# File creator: A.P.
extends Node

enum CurseState {ACTIVE, NON_ACTIVE}

var state: int = CurseState.NON_ACTIVE
var text: String = ""

@export var curse_screen : Node

func _ready():
	set_process_unhandled_key_input(false)

# Curse input is handled here
func _process(delta):
	# Start a curse
	if Input.is_action_just_pressed("start_curse") && state == CurseState.NON_ACTIVE:
		state = CurseState.ACTIVE
		set_process_unhandled_key_input(true)
	# End a curse
	elif Input.is_action_just_pressed("end_curse") && state == CurseState.ACTIVE:
		state = CurseState.NON_ACTIVE
		set_process_unhandled_key_input(false)
		
		# Check if text is a correct curse
		if valid_curse(text.to_lower()):
			print("Cast " + text)
			curse_screen.set_curse(text.to_lower())
			curse_screen.visible = true
			set_process_unhandled_key_input(false)
			set_process(false)
		text = ""

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and !event.is_action("end_curse"):
			text += event.as_text_key_label()
			print(text)

# Return whether text is a valid curse
func valid_curse(curse):
	return $"/root/GlobalVariables".curse_words.has(curse)
