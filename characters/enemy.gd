class_name Enemy extends CharacterBody2D

enum EnemyState {MOVABLE, ATTACKED, ATTACKING}

@export var speed = 100
@export var health : int

var direction : Vector2
var state : EnemyState = EnemyState.MOVABLE:
	set(value):
		match value:
			EnemyState.MOVABLE:
				process_mode = Node.PROCESS_MODE_INHERIT
			EnemyState.ATTACKED:
				process_mode = Node.PROCESS_MODE_DISABLED
			EnemyState.ATTACKING:
				process_mode = Node.PROCESS_MODE_DISABLED

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

func _ready():
	y_sort_enabled = true

# Should return a normalized vector
func get_direction():
	return Vector2(-1, 0)

func _physics_process(delta):
	direction = get_direction()
	velocity = direction * speed
	move_and_collide(velocity*delta)

func _process(delta):
	if direction.length() > 0:
		if direction.x < 0:
			sprite.play("left")
		elif direction.x > 0:
			sprite.play("right")
		elif direction.y > 0:
			sprite.play("down")
		elif direction.y < 0:
			sprite.play("up")
	else:
		sprite.stop();
