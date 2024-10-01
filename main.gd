# Main will be used for everything to do with levels
# Title screen will be a separate scene that loads main
extends Node

@onready var curse_controller = $CurseController
@onready var curse_screen = $MiniGame/CurseScreen
@onready var camera = $World/SubViewport/Level/Camera2D
@onready var player = $World/SubViewport/Player

var current_level = 1 # The current level, corresponding to the keys in level_information
var enemies_escaped = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player.reparent($World/SubViewport/Level)
	player.curse_screen = curse_screen
	player.position = $World/SubViewport/Level/PlayerPosition.position
	
	player.died.connect(_on_player_died)
	
	camera.target = player
	
	curse_controller.player = player
	
	assert($"/root/GlobalVariables".level_information[current_level]["path"] == $World/SubViewport/Level.scene_file_path)
	
	$World/SubViewport/Level/EscapeZone.area_entered.connect(_on_escaped)
	
	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_died():
	game_over.bind("You died!").call_deferred()

func game_over(game_end_reason : String):
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	$Popups/GameOver/BoxContainer/GameOverLabel.text = game_end_reason
	$Popups/GameOver/BoxContainer/RetryButton.disabled = false
	
	$Popups.visible = true
	$Popups/GameOver.visible = true

func reload_level():
	print("Reloaded the level " + $"/root/GlobalVariables".level_information[current_level]["path"])
	
	$Popups.visible = false
	
	for popup in $Popups.get_children():
		popup.visible = false
	
	# Move player out of level, remove level, and reload it
	player.reparent($World/SubViewport)
	$World/SubViewport/Level.free()
	$World/SubViewport.add_child(load($"/root/GlobalVariables".level_information[current_level]["path"]).instantiate(), true)
	camera = $World/SubViewport/Level/Camera2D
	
	$World/SubViewport/Level/EscapeZone.area_entered.connect(_on_escaped)
	
	player.reparent($World/SubViewport/Level)
	player.position = $World/SubViewport/Level/PlayerPosition.position
	camera.target = player
	player.state = Player.PlayerState.MOVABLE
	player.sprite.play("right")
	player.sprite.stop()
	
	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)
	
	$World.process_mode = Node.PROCESS_MODE_INHERIT

func load_next_level():
	print("Loaded the next level ")

func _on_escaped(area: Node):
	if area.get_parent() is Enemy:
		var enemy : Enemy = area.get_parent()
		enemies_escaped += 1
		print("Enemy escaped")

		if (enemies_escaped > $"/root/GlobalVariables".level_information[current_level]["escapes_allowed"]):
			game_over.bind("More than " + String.num_int64($"/root/GlobalVariables".level_information[current_level]["escapes_allowed"]) + " enemies escaped!").call_deferred()
		
		enemy.queue_free()

func _on_enemy_exited_tree():
	if get_tree().get_node_count_in_group("enemies") > 0:
			print("Enemies still exist on map")
	else:
			print("Cleared all enemies on the map")

func _on_retry_button_pressed():
	$Popups/GameOver/BoxContainer/RetryButton.disabled = true
	reload_level()
