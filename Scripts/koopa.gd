extends Enemy

class_name Koopa

const KOOPA_SHELL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const KOOPA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")
const KOOPA_SHELL_COLLISION_SHAPE_POSITION = Vector2(0, -2)
const KOOPA_NORMAL_COLLISION_SHAPE_POSITON = Vector2(0, 0)

const STOMP_Y_VELOCITY = -50
const SHELL_X_SPEED = 400

var in_shell = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move(delta)
	move_and_slide()

func move(delta):
	position.x += direction * delta * speed_x

func stomped(playerPosition : Vector2):
	ScoreUtils.spawn_points_label(area_2d, 100)
	if (in_shell):
		launch(playerPosition)
	else:
		toShell()

func launch(playerPosition : Vector2):
	if playerPosition.x > global_position.x:
		speed_x = SHELL_X_SPEED
	else:
		speed_x = -SHELL_X_SPEED

func toShell():
	update_collision_shape(KOOPA_SHELL_COLLISION_SHAPE, KOOPA_SHELL_COLLISION_SHAPE_POSITION)
	animated_sprite_2d.play("shell")
	speed_x = 0
	velocity.y = STOMP_Y_VELOCITY
	in_shell = true
	area_2d.set_collision_mask_value(3, true)

func backToNormal():
	velocity.y = STOMP_Y_VELOCITY
	update_collision_shape(KOOPA_NORMAL_COLLISION_SHAPE, KOOPA_NORMAL_COLLISION_SHAPE_POSITON)
	animated_sprite_2d.play("move")
	speed_x = SPEED_DEFAULT
	in_shell = false
	area_2d.set_collision_mask_value(3, false)

func death():
	super.death()
	speed_x = 0
	speed_y = 0
	animated_sprite_2d.play("death")

func _on_area_2d_area_entered(area):
	if area.get_parent().name == "Goomba":
		print("击中友军!")
		area.get_parent().killed()
