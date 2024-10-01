extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var audioLevel = $AudioStreamPlayer.get_volume_db()
	while true:
		$AudioStreamPlayer.set_volume_db(audioLevel)
		audioLevel = audioLevel-1
		await(get_tree().create_timer(0.06).timeout)
		if $AudioStreamPlayer.get_volume_db() < -30:
			break
	get_tree().change_scene_to_file("res://main.tscn")
	
