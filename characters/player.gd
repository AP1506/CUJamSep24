class_name Player extends CharacterBody2D

enum PlayerState {MOVABLE, ATTACKED, ATTACKING, HEALING, TYPING, DEAD}

signal cast_curse(curse_name: String, damage: int)
signal died

@export var speed = 400
@export var init_health = 400
var health : int:
	set(value):
		if value < 0:
			value = 0
		elif value > init_health:
			value = init_health
		health = value
		health_label.text = "Health: " + String.num_int64(health)

@export var curse_screen : CurseScreen
@export var curse_controller : CurseController
@export var health_label : Label

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
			PlayerState.DEAD:
				set_physics_process(false)
				set_process(false)
				$AttackableArea.set_deferred("monitorable", false)
				curse_controller.curse_state = CurseController.CurseState.NON_ACTIVE
				curse_controller.typing_state = CurseController.CurseState.NON_ACTIVE
				curse_controller.text = ""
		state = value
		print("player state is now " + PlayerState.keys()[value])

var curse_being_cast : String
var attack_damage : int

var init_offset : Vector2
var animation_direction : String = "left"

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var spell_area = $SpellArea
@onready var dmg_label = $DmgLabel

func _ready():
	curse_screen.curse_casted.connect(_on_curse_casted)
	anim_player.animation_finished.connect(_on_animation_finished)
	health = init_health
	
	animation_direction = sprite.animation
	
	init_offset = sprite.offset

func new_level():
	health = init_health
	state = Player.PlayerState.MOVABLE
	sprite.play("right")
	sprite.stop()
	anim_player.stop()
	anim_player.seek(0)
	
	curse_controller.curse_state = CurseController.CurseState.ACTIVE
	curse_controller.typing_state = CurseController.CurseState.NON_ACTIVE
	curse_controller.text = ""

func die():
	state = PlayerState.DEAD
	
	anim_player.play("player_curse_anims/attacked_" + animation_direction)

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
			animation_direction = "left"
		elif Input.is_action_pressed("move_right"):
			sprite.play("right")
			animation_direction = "right"
		elif Input.is_action_pressed("move_down"):
			sprite.play("down")
			animation_direction = "down"
		elif Input.is_action_pressed("move_up"):
			sprite.play("up")
			animation_direction = "up"
	elif Input.is_action_just_released("move_down") || Input.is_action_just_released("move_left") || Input.is_action_just_released("move_right") || Input.is_action_just_released("move_up"):
		if Input.is_action_just_released("move_down"):
			sprite.play("down")
			animation_direction = "down"
		elif Input.is_action_just_released("move_left"):
			sprite.play("left")
			animation_direction = "left"
		elif Input.is_action_just_released("move_right"):
			sprite.play("right")
			animation_direction = "right"
		elif Input.is_action_just_released("move_up"):
			sprite.play("up")
			animation_direction = "up"
		
		sprite.stop()

func _on_curse_casted(curse_name: String, accuracy: int):
	state = PlayerState.ATTACKING
	curse_being_cast = curse_name

	print("Cast " + curse_name.to_upper() + " with " + String.num_int64(accuracy) + "% accuracy")
	
	var success = true # Whether the spell succeeds or not
	var damage
	
	match curse_name:
		"ward":
			if accuracy >= 25:
				damage = 100
				attack_damage = damage - damage * ((100 - accuracy) * 0.66 / 100.0)
				anim_player.play("player_curse_anims/ward_" + animation_direction) # Temp
			else:
				success = false
		"tear":
			if accuracy >= 50:
				damage = 25
				attack_damage = damage - damage * ((100 - accuracy) * 0.6 / 100.0)
				anim_player.play("player_curse_anims/magic_" + animation_direction) # Temp
			else:
				success = false
		"east":
			if accuracy >= 50:
				damage = 30
				attack_damage = damage - damage * ((100 - accuracy) * 0.6 / 100.0)
				anim_player.play("player_curse_anims/magic_" + animation_direction) # Temp
		_:
			push_error("Cast unknown curse, " + curse_name)
			success = false
	
	if not success:
		anim_player.play("player_curse_anims/failed_spell")

func heal(heal : int):
	health += heal
	
	dmg_label.text = "+" + String.num_int64(heal)
	
	state = PlayerState.HEALING
	anim_player.play("player_curse_anims/heal")

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
	if (health > 0):
		anim_player.play("player_curse_anims/attacked_" + animation_direction)
	else:
		die()

func _on_animation_finished(anim_name):
	print(anim_name)
	if state == PlayerState.ATTACKING and ("magic_" in anim_name || "failed_spell" in anim_name || curse_being_cast in anim_name):
		sprite.offset = init_offset
		anim_player.play("player_curse_anims/RESET")
		sprite.play(animation_direction)
		sprite.stop()
		sprite.frame = 0
		
		match curse_being_cast:
			#"tear":
				#pass # The enemy should call heal back on the player
			_:
				state = PlayerState.MOVABLE
		
	elif state == PlayerState.ATTACKED and ("attacked" in anim_name):
		anim_player.play("player_curse_anims/RESET")
		sprite.play(animation_direction)
		sprite.stop()
		sprite.frame = 0

		state = PlayerState.MOVABLE
	elif state == PlayerState.DEAD and ("attacked" in anim_name):
		died.emit()
	elif state == PlayerState.HEALING:
		anim_player.play("player_curse_anims/RESET")
		sprite.play(animation_direction)
		sprite.stop()
		sprite.frame = 0
		
		state = PlayerState.MOVABLE
