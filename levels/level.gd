extends Node2D

@onready var player_position = $PlayerPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	y_sort_enabled = true
