class_name Player extends CharacterBody2D

enum PlayerState {MOVABLE, ATTACKED, ATTACKING, TYPING}

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
				curse_controller.curse_state = CurseController.CurseState.ACTIVE
			PlayerState.ATTACKED:
				set_physics_process(false)
				set_process(false)
				curse_controller.curse_state = CurseController.CurseState.NON_ACTIVE
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

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer

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

	print("Cast " + curse_name.to_upper() + " with " + String.num_int64(accuracy) + "% accuracy")

	anim_player.play("magic_" + sprite.animation) # Temp
	#anim_player.play(curse_name + "_" + sprite.animation)

func _on_animation_finished(anim_name):
	if state == PlayerState.ATTACKING:
		anim_player.play("finished_attack")
		sprite.play(sprite.animation.trim_prefix("magic_"))
		sprite.stop()
		sprite.frame = 0

		state = PlayerState.MOVABLE
