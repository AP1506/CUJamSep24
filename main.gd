# Main will be used for everything to do with levels
# Title screen will be a separate scene that loads main
extends Node

@onready var curse_controller = $CurseController
@onready var curse_screen = $MiniGame/CurseScreen
@onready var camera = $World/SubViewport/Level/Camera2D
@onready var player = $World/SubViewport/Player

@onready var escaped_label = $UI2/EscapedLabel
@onready var time_label = $UI2/TimeLabel

@onready var game_over_label = $Popups/GameOver/BoxContainer/GameOverLabel
@onready var time_elapsed_popup_label = $Popups/GameOver/BoxContainer/HBoxContainer/TimeElapsedLabel
@onready var best_time_label = $Popups/GameOver/BoxContainer/HBoxContainer/BestTimeLabel

@onready var retry_button = $Popups/GameOver/BoxContainer/HBoxContainer2/RetryButton
@onready var next_level_button = $Popups/GameOver/BoxContainer/HBoxContainer2/NextLevelButton

var current_level = 1 # The current level, corresponding to the keys in level_information
var enemies_escaped = 0:
	set(value):
		enemies_escaped = value
		escaped_label.text = "Escaped " + String.num_int64(value) + "/" + String.num_int64($"/root/GlobalVariables".level_information[current_level]["escapes_allowed"] + 1)
var all_enemies_defeated = false

var timer = 0:
	set(value):
		timer = value
		time_label.text = "Time elapsed: " + String.num_int64(int(value) / 60) + ":" + ("0" if int(value) % 60 < 10 else "") + String.num_int64(int(value) % 60)
var timer_on = true

var loading_level : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player.reparent($World/SubViewport/Level)
	player.curse_screen = curse_screen
	player.position = $World/SubViewport/Level/PlayerPosition.position
	
	player.died.connect(_on_player_died)
	
	camera.target = player
	set_camera_limits()
	
	curse_controller.player = player
	
	assert($"/root/GlobalVariables".level_information[current_level]["path"] == $World/SubViewport/Level.scene_file_path)
	
	$World/SubViewport/Level/EscapeZone.area_entered.connect(_on_escaped)
	
	enemies_escaped = 0
	
	timer = 0
	
	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)

func set_camera_limits():
	var map_limits = $World/SubViewport/Level/TileMapLayer.get_used_rect()
	var map_cellsize = Vector2($World/SubViewport/Level/TileMapLayer.tile_set.tile_size) * $World/SubViewport/Level.scale
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.state != Player.PlayerState.TYPING:
		$Guidebook.visible = false
	else:
		$Guidebook.visible = true

func _physics_process(delta):
	if timer_on:
		timer += delta

func _on_player_died():
	game_over.bind("You died!").call_deferred()

# For winning and losing conditions
func game_over(game_end_reason : String, success : bool = false):
	$World.process_mode = Node.PROCESS_MODE_DISABLED
	$Popups/GameOver/BoxContainer/GameOverLabel.text = game_end_reason
	retry_button.disabled = false
	timer_on = false
	
	curse_screen.take_down_screen()
	curse_controller.curse_state = CurseController.CurseState.NON_ACTIVE
	
	time_elapsed_popup_label.text = "Time elapsed: " + String.num_int64(int(timer) / 60) + ":" + ("0" if int(timer) % 60 < 10 else "") + String.num_int64(int(timer) % 60)
	
	var best_time = $"/root/GlobalVariables".level_information[current_level]["best_completion_time"]
	
	if (best_time == null or timer < best_time) and success:
		$"/root/GlobalVariables".level_information[current_level]["best_completion_time"] = timer
		best_time_label.text = "*Best Time: " + String.num_int64(int(timer) / 60) + ":" + ("0" if int(timer) % 60 < 10 else "") + String.num_int64(int(timer) % 60)
	elif best_time == null:
		best_time_label.text = "Best Time: Not completed"
	else:
		best_time_label.text = "Best Time: " + String.num_int64(int(best_time) / 60) + ":" + ("0" if int(best_time) % 60 < 10 else "") + String.num_int64(int(best_time) % 60)
	
	$Popups.visible = true
	$Popups/GameOver.visible = true

func load_level(level_number : int):
	print("Loaded the level " + $"/root/GlobalVariables".level_information[level_number]["path"])
	loading_level = true
	
	current_level = level_number
	
	$Popups.visible = false
	
	for popup in $Popups.get_children():
		popup.visible = false
	
	# Move player out of level, remove level, and reload it
	player.reparent($World/SubViewport)
	$World/SubViewport/Level.free()
	$World/SubViewport.add_child(load($"/root/GlobalVariables".level_information[level_number]["path"]).instantiate(), true)
	camera = $World/SubViewport/Level/Camera2D
	
	set_camera_limits()
	
	$World/SubViewport/Level/EscapeZone.area_entered.connect(_on_escaped)
	
	player.reparent($World/SubViewport/Level)
	player.position = $World/SubViewport/Level/PlayerPosition.position
	camera.target = player
	player.new_level()
	
	enemies_escaped = 0
	timer = 0
	
	# Enemy set up
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.player = player
		enemy.connect_on_attacked(player.spell_area.area_entered, player)
		player.connect_on_attacked(enemy.attack_area.area_entered, enemy)
		enemy.tree_exited.connect(_on_enemy_exited_tree)
	
	$AudioStreamPlayer.restart_playing()
	
	loading_level = false
	
	# Allow inputs
	timer_on = true
	curse_controller.curse_state = CurseController.CurseState.ACTIVE
	$World.process_mode = Node.PROCESS_MODE_INHERIT

func reload_level():
	load_level(current_level)

func load_next_level():
	print("Loaded the next level ")
	load_level(current_level + 1 if $"/root/GlobalVariables".level_information.keys().size() > current_level + 1 else current_level)

func load_previous_level():
	print("Loaded the previous level ")
	load_level(current_level - 1 if current_level - 1 > 0 else current_level)

func _on_escaped(area: Node):
	if area.get_parent() is Enemy:
		var enemy : Enemy = area.get_parent()
		enemies_escaped += 1
		print("Enemy escaped")

		if (enemies_escaped > $"/root/GlobalVariables".level_information[current_level]["escapes_allowed"]):
			game_over.bind("More than " + String.num_int64($"/root/GlobalVariables".level_information[current_level]["escapes_allowed"]) + " enemies escaped!").call_deferred()
		
		enemy.queue_free()

func _on_enemy_exited_tree():
	# This function also may be called when closing the window, loading the next level, and an enemy escaping
	if !get_tree():
		return
	if get_tree().get_node_count_in_group("enemies") > 0:
			print("Enemies still exist on map")
	elif not loading_level and enemies_escaped <= $"/root/GlobalVariables".level_information[current_level]["escapes_allowed"]:
			print("Cleared all enemies on the map")
			game_over.bind("Success!", true).call_deferred()

func _on_retry_button_pressed():
	retry_button.disabled = true
	$AudioStreamPlayer.stop_playing()
	reload_level.call_deferred()


func _on_next_level_button_pressed():
	load_next_level.call_deferred()


func _on_previous_level_button_pressed():
	load_previous_level.call_deferred()
