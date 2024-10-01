class_name Player extends CharacterBody2D

enum PlayerState {MOVABLE, ATTACKED, ATTACKING, TYPING}

signal cast_curse(curse_name: String, damage: int)

@export var speed = 400
@export var health = 400

@export var curse_screen : CurseScreen
@export var curse_controller : CurseController

var state : PlayerState = PlayerState.MOVABLE:
	set(value):
		match value:
			PlayerState.MOVABLE:
				set_physics_process(true)
				set_process(true)
				$AttackableArea.set_deferred("monitorable", true)
				curse_controller.curse_state = CurseController.CurseState.ACTIVE
			PlayerState.ATTACKED:
				set_physics_process(false)
				set_process(false)
				$AttackableArea.set_deferred("monitorable", false)
				curse_controller.curse_state = CurseController.CurseState.NON_ACTIVE
				curse_controller.typing_state = CurseController.CurseState.NON_ACTIVE
				curse_controller.text = ""
			PlayerState.ATTACKING:
				set_physics_process(false)
				set_process(false)
				curse_controller.curse_state = CurseController.CurseState.NON_ACTIVE
			PlayerState.TYPING:
				set_physics_process(false)
				set_process(false)
				sprite.pause()
				sprite.frame = 0
		state = value
		print("player state is now " + PlayerState.keys()[value])

var curse_being_cast : String
var attack_damage : int

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var spell_area = $SpellArea
@onready var dmg_label = $DmgLabel

func _ready():
	curse_screen.curse_casted.connect(_on_curse_casted)
	anim_player.animation_finished.connect(_on_animation_finished)

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_collide(velocity*delta)

func _process(delta):
	if Input.is_anything_pressed():
		if Input.is_action_pressed("move_left"):
			sprite.play("left")
		elif Input.is_action_pressed("move_right"):
			sprite.play("right")
		elif Input.is_action_pressed("move_down"):
			sprite.play("down")
		elif Input.is_action_pressed("move_up"):
			sprite.play("up")
	elif Input.is_action_just_released("move_down") || Input.is_action_just_released("move_left") || Input.is_action_just_released("move_right") || Input.is_action_just_released("move_up"):
		if Input.is_action_just_released("move_down"):
			sprite.play("down")
		elif Input.is_action_just_released("move_left"):
			sprite.play("left")
		elif Input.is_action_just_released("move_right"):
			sprite.play("right")
		elif Input.is_action_just_released("move_up"):
			sprite.play("up")
		
		sprite.stop()

func _on_curse_casted(curse_name: String, accuracy: int):
	state = PlayerState.ATTACKING
	curse_being_cast = curse_name

	print("Cast " + curse_name.to_upper() + " with " + String.num_int64(accuracy) + "% accuracy")
	
	match curse_name:
		"fear":
			attack_damage = 50
		_:
			push_error("Cast unknown curse, " + curse_name)

	anim_player.play("player_curse_anims/magic_" + sprite.animation) # Temp
	#anim_player.play("player_curse_anims/" + curse_name + "_" + sprite.animation)

func connect_on_attacked(sig: Signal, attacker : Node):
	sig.connect(_on_attacked.bind(attacker))

func _on_attacked(playerArea : Area2D, attacker):
	if playerArea.get_parent() != self:
		return
	
	assert(attacker is Enemy)
	attacker.on_attacking()
	
	print("Player attacked with " + String.num_int64(attacker.attack_damage))
	state = PlayerState.ATTACKED
	
	dmg_label.text = "-" + String.num_int64(attacker.attack_damage)
	
	health -= attacker.attack_damage
	
	anim_player.play("player_curse_anims/attacked_" + sprite.animation)

func _on_animation_finished(anim_name):
	if state == PlayerState.ATTACKING:
		anim_player.play("player_curse_anims/finished_attack")
		sprite.play(sprite.animation.trim_prefix("magic_"))
		sprite.stop()
		sprite.frame = 0

		state = PlayerState.MOVABLE
	elif state == PlayerState.ATTACKED:
		sprite.play(sprite.animation.trim_prefix("attacked_"))
		sprite.stop()
		sprite.frame = 0

		state = PlayerState.MOVABLE
