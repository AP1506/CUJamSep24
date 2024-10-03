class_name Level extends Node2D

@onready var player_position = $PlayerPosition
@onready var escape_zone = $EscapeZone
@onready var camera = $Camera2D
@onready var tile_map = $TileMapLayer
@onready var next_level_zone = $NextLevelZone

# Called when the node enters the scene tree for the first time.
func _ready():
	y_sort_enabled = true
	camera.position.x = player_position.position.x
