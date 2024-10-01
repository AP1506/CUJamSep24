class_name Level extends Node2D

@onready var player_position = $PlayerPosition
@onready var escape_zone = $EscapeZone
@onready var camera = $Camera2D
@onready var tile_map = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	y_sort_enabled = true
