# Main will be used for everything to do with levels
# Title screen will be a separate scene that loads main
extends Node

@onready var curse_controller = $CurseController
@onready var curse_screen = $CurseScreen
@onready var camera = $World/SubViewport/Camera2D
@onready var player = $World/SubViewport/Player

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.target = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
