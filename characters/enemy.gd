class_name Enemy extends CharacterBody2D

enum EnemyState {MOVABLE, ATTACKED, ATTACKING, DEAD}
enum EnemyMove {NORMAL, PUSHED}

@export var speed = 100
@export var push_speed : float = 1 # Applicable when move_state is PUSHED. Use to convey mass
@export var health : int = 100

var player : Node

var direction : Vector2 # Used during normal movement and for animations
var pushed_direction : Vector2 # Used during pushed movement. Should be a normalized vector
var animation_direction : String = "left"

var attack_damage : int = 50

var push : int = 0 # The total amount to push the enemy, only appicable in move_state = PUSHED
var pushed : float = 0 # The amount the enemy has been pushed in the pushed state
var previous_position : Vector2 # Used to calculate pushed
var base_push_speed : int = 75

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
		print("enemy state is now " + EnemyState.keys()[value])
var move_state : EnemyMove = EnemyMove.NORMAL:
	set(value):
		match value:
			EnemyMove.NORMAL:
				pass
			EnemyMove.PUSHED:
				pushed = 0
				previous_position = position
		
		move_state = value
		print("enemy move_state is now " + EnemyMove.keys()[value])

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var dmg_label = $DmgLabel
@onready var anim_player = $AnimationPlayer

func _ready():
	add_to_group("enemies")
	
	anim_player.animation_finished.connect(_on_animation_finished)

# Should return a normalized vector
# Calculates the direction during normal movement
func get_direction():
	return Vector2(-1, 0)

func die():
	state = EnemyState.DEAD
	
	anim_player.play("enemy_anims/dead_" + animation_direction)
	

func _physics_process(delta):
	if move_state == EnemyMove.NORMAL:
		direction = get_direction()
		velocity = direction * speed
		move_and_collide(velocity*delta)
	elif move_state == EnemyMove.PUSHED:
		velocity = pushed_direction * base_push_speed * push_speed
		move_and_collide(velocity * delta)
		
		pushed += (position - previous_position).length()
		
		previous_position = position
		
		if pushed >= push * push_speed:
			move_state = EnemyMove.NORMAL

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
		
		direction = Vector2(0, 0)
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
			health -= attacker.attack_damage
			
			if (health > 0):
				anim_player.play("enemy_anims/attacked_" + animation_direction)
			else:
				die()
		"east":
			pushed_direction = $"/root/GlobalVariables".dir_to_v[attacker.animation_direction]
			push = attacker.attack_damage
			
			move_state = EnemyMove.PUSHED
			
			if (health > 0):
				anim_player.play("enemy_anims/pushed_" + animation_direction)
			else:
				die()
		_:
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
