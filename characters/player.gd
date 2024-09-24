extends CharacterBody2D

@export var speed = 400

@onready var sprite = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

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
