# Main will be used for everything to do with levels
# Title screen will be a separate scene that loads main
extends Node

@onready var curse_controller = $CurseController
@onready var curse_screen = $MiniGame/CurseScreen
@onready var camera = $World/SubViewport/Level/Camera2D
@onready var player = $World/SubViewport/Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.reparent($World/SubViewport/Level)
	camera.target = player
	curse_controller.player = player
	player.curse_screen = curse_screen
	player.position = $World/SubViewport/Level/PlayerPosition.position

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_exited_tree():
	if get_tree().get_node_count_in_group("enemies") > 0:
			print("Enemies still exist on map")
	else:
			print("Cleared all enemies on the map")
