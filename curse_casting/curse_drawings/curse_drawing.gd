# File Creator: A.P.
class_name CurseDrawing extends Node2D

# Keep all these invisible when running the game
@export var elements : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	for element in elements:
		element.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
