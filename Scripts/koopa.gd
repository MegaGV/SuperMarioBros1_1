extends Enemy

const KOOPA_SHELL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const KOOPA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")
const KOOPA_SHELL_COLLISION_SHAPE_POSITION = Vector2(0, -2)
const KOOPA_NORMAL_COLLISION_SHAPE_POSITON = Vector2(0, 0)

const STOMP_Y_VELOCITY = -50
const SHELL_X_SPEED = 400

var is_shell = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	walk(delta)
	move_and_slide()

func walk(delta):
	position.x += direction * delta * speed_x

func stomped(angle_of_collision : float):
	if (is_shell):
		if angle_of_collision > 90:
			speed_x = SHELL_X_SPEED
		else:
			speed_x = -SHELL_X_SPEED
	else:
		update_collision_shape(KOOPA_SHELL_COLLISION_SHAPE, KOOPA_SHELL_COLLISION_SHAPE_POSITION)
		animated_sprite_2d.play("shell")
		speed_x = 0
		velocity.y = STOMP_Y_VELOCITY
		is_shell = true


func backToNormal():
	velocity.y = STOMP_Y_VELOCITY
	update_collision_shape(KOOPA_NORMAL_COLLISION_SHAPE, KOOPA_NORMAL_COLLISION_SHAPE_POSITON)
	animated_sprite_2d.play("walk")
	speed_x = SPEED_DEFAULT
	is_shell = false

func death():
	super.death()
	speed_x = 0
	speed_y = 0
	animated_sprite_2d.play("death")
