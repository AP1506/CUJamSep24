extends Camera2D

var target = null

#Code taken from ref 1
func _physics_process(delta):
	if target:
		position = target.position
