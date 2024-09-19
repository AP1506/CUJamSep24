# File Creator: A.P.

class_name CurseButton extends TextureButton

signal curse_press

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("curse_drawing_press") && is_hovered():
		curse_press.emit()
