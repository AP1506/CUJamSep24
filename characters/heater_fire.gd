extends Enemy

func _ready():
	add_to_group("enemies")
	
	#anim_player.animation_finished.connect(_on_animation_finished)

# Should return a normalized vector
func get_direction():
	pass

func die():
	state = EnemyState.DEAD
	queue_free()
	#anim_player.play("enemy_anims/dead_" + sprite.animation)

func _physics_process(delta):
	pass

func _process(delta):
	pass

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
		#anim_player.play("enemy_anims/attacked_" + sprite.animation)
		print("Heater Fire alive with "+str(health)+" HP")
	else:
		print("Heater Fire killed.")
		die()

func on_attacking():
	state = EnemyState.ATTACKING
	await(0.5)
	state = EnemyState.MOVABLE
	#anim_player.play("enemy_anims/magic_" + sprite.animation)

func _on_animation_finished(anim_name):
	if state == EnemyState.ATTACKED:
		#sprite.play(sprite.animation.trim_prefix("attacked_"))
		#sprite.stop()
		#sprite.frame = 0
		print("attacked")

		state = EnemyState.MOVABLE
	elif state == EnemyState.ATTACKING:
		#sprite.play(sprite.animation.trim_prefix("magic_"))
		#sprite.stop()
		#sprite.frame = 0
		print("attacking")

		state = EnemyState.MOVABLE
	elif state == EnemyState.DEAD:
		queue_free()
