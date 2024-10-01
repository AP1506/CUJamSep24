# Main will be used for everything to do with levels
# Title screen will be a separate scene that loads main
extends Node

@onready var curse_controller = $CurseController
@onready var curse_screen = $MiniGame/CurseScreen
@onready var camera = $World/SubViewport/Level/Camera2D
@onready var player = $World/SubViewport/Player

@onready var current_level = $World/SubViewport/Level.scene_file_path

# Called when the node enters the scene tree for the first time.
func _ready():
	player.reparent($World/SubViewport/Level)
	player.curse_screen = curse_screen
	player.position = $World/SubViewport/Level/PlayerPosition.position
	
	player.died.connect(_game_over)
	
	camera.target = player
	
	curse_controller.player = player

	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.typingState == 0:
		$ColorRect.visible = false
		$Guidebook.visible = false
	elif player.typingState == 1:
		$ColorRect.visible = true
		$Guidebook.visible = true
		
	pass

func _game_over():
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	$Popups.visible = true
	$Popups/GameOver.visible = true
	$Popups/GameOver/BoxContainer/RetryButton.disabled = false

func reload_level():
	print("Reloaded the level " + current_level)
	
	$Popups.visible = false
	
	for popup in $Popups.get_children():
		popup.visible = false
	
	player.reparent($World/SubViewport)
	$World/SubViewport/Level.free()
	$World/SubViewport.add_child(load(current_level).instantiate(), true)
	camera = $World/SubViewport/Level/Camera2D
	
	player.reparent($World/SubViewport/Level)
	player.position = $World/SubViewport/Level/PlayerPosition.position
	camera.target = player
	player.state = Player.PlayerState.MOVABLE
	
	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)
	
	$World.process_mode = Node.PROCESS_MODE_INHERIT

func load_next_level():
	print("Loaded the next level ")

func _on_enemy_exited_tree():
	if get_tree().get_node_count_in_group("enemies") > 0:
			print("Enemies still exist on map")
	else:
			print("Cleared all enemies on the map")

func _on_retry_button_pressed():
	$Popups/GameOver/BoxContainer/RetryButton.disabled = true
	reload_level()
