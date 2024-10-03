extends Enemy

func _ready():
	add_to_group("enemies")
	
	anim_player.animation_finished.connect(_on_animation_finished)

# Should return a normalized vector
func get_direction():
	pass

func die():
	state = EnemyState.DEAD
	$AnimationPlayer.play("fire_enemy_anims/dead")

func _physics_process(delta):
	pass

func _process(delta):
	$AnimationPlayer.play("fire_enemy_anims/idle")

func connect_on_attacked(sig: Signal, attacker : Node):
	sig.connect(_on_attacked.bind(attacker))

func _on_attacked(enemy_area : Area2D, attacker):
	if enemy_area.get_parent() != self:
		return
	assert(attacker is Player)
	
	print("Heater Fire attacked with " + String.num_int64(attacker.attack_damage))
	state = EnemyState.ATTACKED
	
	dmg_label.text = String.num_int64(attacker.attack_damage)
	
	health -= attacker.attack_damage
	
	if (health > 0):
		print("Heater Fire alive with "+str(health)+" HP")
	else:
		die()

func on_attacking():
	state = EnemyState.ATTACKING
	#await(0.5)
	#state = EnemyState.MOVABLE
	$AnimationPlayer.play("fire_enemy_anims/attacking")

func _on_animation_finished(anim_name):
	if state == EnemyState.ATTACKED:
		sprite.play("idle")
		sprite.stop()
		sprite.frame = 0
		print("Heater Fire finished being attacked")

		state = EnemyState.MOVABLE
	elif state == EnemyState.ATTACKING:
		sprite.play("idle")
		sprite.stop()
		sprite.frame = 0
		print("Heater Fire finished attacking")

		state = EnemyState.MOVABLE
	elif state == EnemyState.DEAD:
		print("Heater Fire killed.")
		queue_free()
