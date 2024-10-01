# File creator: A.P.
class_name CurseController extends Node

enum CurseState {ACTIVE, NON_ACTIVE}

# curse_state is for enabling cursing

# ACTIVE is when you can start typing curses
# NON_ACTIVE is when you can't start type curses
var curse_state: int = CurseState.ACTIVE:
	set(value):
		if value == CurseState.ACTIVE:
			set_process(true)
		elif value == CurseState.NON_ACTIVE:
			set_process(false)
			set_process_unhandled_key_input(false)
		curse_state = value
		print("curse_state is now " + CurseState.keys()[value])

# typing_state shows whether the player is typing or not
# ACTIVE is when you can type curses
# NON_ACTIVE is when you can't type curses
var typing_state: int = CurseState.NON_ACTIVE:
	set(value):
		if value == CurseState.ACTIVE:
			set_process_unhandled_key_input(true)
			player.state = Player.PlayerState.TYPING
		elif value == CurseState.NON_ACTIVE:
			set_process_unhandled_key_input(false)
		typing_state = value
		print("typing_state is now " + CurseState.keys()[value])

var text: String = "":
	set(value):
		text = value
		display.text = value

@export var curse_screen : Node
@export var display : Label
@export var player : Node
@export var world : Node

func _ready():
	set_process_unhandled_key_input(false)
	display.text = ""

# Curse input is handled here
func _process(delta):
	# Start a curse
	if Input.is_action_just_released("start_curse") && typing_state == CurseState.NON_ACTIVE:
		typing_state = CurseState.ACTIVE
	# End a curse
	elif Input.is_action_just_pressed("end_curse") && typing_state == CurseState.ACTIVE:
		typing_state = CurseState.NON_ACTIVE
		player.state = Player.PlayerState.MOVABLE
		
		# Check if text is a correct curse
		if valid_curse(text.to_lower()):
			print("Started curse  " + text)
			
			# Set up the curse screen
			curse_screen.set_curse(text.to_lower())
			curse_screen.make_visible(true)
			
			# Disable other processes
			world.process_mode = Node.PROCESS_MODE_DISABLED
			curse_state = CurseState.NON_ACTIVE
		text = ""

func _unhandled_key_input(event):
	if event is InputEventKey:
		# Ideally would only consider alphabet keys
		if event.pressed and !event.is_action("end_curse"):
			text += event.as_text_key_label()
			print(text)

# Return whether text is a valid curse
func valid_curse(curse):
	return $"/root/GlobalVariables".curse_words.has(curse)
