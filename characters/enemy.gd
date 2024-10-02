class_name Enemy extends CharacterBody2D

enum EnemyState {MOVABLE, ATTACKED, ATTACKING, DEAD}

@export var speed = 100
@export var health : int = 100

var player : Node

var direction : Vector2
var animation_direction : String = "left"
var attack_damage : int = 50
var state : EnemyState = EnemyState.MOVABLE:
	set(value):
		match value:
			EnemyState.MOVABLE:
				set_physics_process(true)
				set_process(true)
				$AttackArea.set_deferred("monitoring", true)
			EnemyState.ATTACKED:
				set_physics_process(false)
				set_process(false)
			EnemyState.ATTACKING:
				set_physics_process(false)
				set_process(false)
				$AttackArea.set_deferred("monitoring", false)
			EnemyState.DEAD:
				set_physics_process(false)
				set_process(false)
		
		state = value

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var dmg_label = $DmgLabel
@onready var anim_player = $AnimationPlayer

func _ready():
	add_to_group("enemies")
	
	anim_player.animation_finished.connect(_on_animation_finished)

# Should return a normalized vector
func get_direction():
	return Vector2(-1, 0)

func die():
	state = EnemyState.DEAD
	
	anim_player.play("enemy_anims/dead_" + animation_direction)
	

func _physics_process(delta):
	direction = get_direction()
	velocity = direction * speed
	move_and_collide(velocity*delta)

func _process(delta):
	#if anim_player.current_animation:
		#print("Progress of anim " + String.num_int64(anim_player.current_animation_position))
	
	if direction.length() > 0:
		if direction.x < 0:
			anim_player.play("enemy_anims/left")
			animation_direction = "left"
		elif direction.x > 0:
			anim_player.play("enemy_anims/right")
			animation_direction = "right"
		elif direction.y > 0:
			anim_player.play("enemy_anims/down")
			animation_direction = "down"
		elif direction.y < 0:
			anim_player.play("enemy_anims/up")
			animation_direction = "up"
	else:
		sprite.stop();

func connect_on_attacked(sig: Signal, attacker : Node):
	sig.connect(_on_attacked.bind(attacker))

func _on_attacked(enemy_area : Area2D, attacker):
	if enemy_area.get_parent() != self:
		return
	assert(attacker is Player)
	
	print("Enemy attacked with " + String.num_int64(attacker.attack_damage))
	state = EnemyState.ATTACKED
	
	dmg_label.text = String.num_int64(attacker.attack_damage)
	
	match attacker.curse_being_cast:
		"tear":
			player.heal(attacker.attack_damage if attacker.attack_damage <= health else health)
		_:
			pass
	
	health -= attacker.attack_damage
	
	if (health > 0):
		anim_player.play("enemy_anims/attacked_" + animation_direction)
	else:
		die()

func on_attacking():
	state = EnemyState.ATTACKING
	anim_player.play("enemy_anims/magic_" + animation_direction)

func _on_animation_finished(anim_name):
	if state == EnemyState.ATTACKED:
		sprite.play(animation_direction)
		sprite.stop()
		sprite.frame = 0

		state = EnemyState.MOVABLE
	elif state == EnemyState.ATTACKING:
		sprite.play(animation_direction)
		sprite.stop()
		sprite.frame = 0

		state = EnemyState.MOVABLE
	elif state == EnemyState.DEAD:
		queue_free()
