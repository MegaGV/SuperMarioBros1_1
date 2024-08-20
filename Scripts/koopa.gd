extends Enemy

class_name Koopa

const KOOPA_SHELL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const KOOPA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")
const KOOPA_SHELL_COLLISION_SHAPE_POSITION = Vector2(0, -2)
const KOOPA_NORMAL_COLLISION_SHAPE_POSITON = Vector2(0, 0)

const STOMP_VELOCITY_Y = -50
const SHELL_SPEED = 250

var in_shell = false

func _physics_process(delta):
	basic_move(delta)
	move(delta)
	move_and_slide()

func move(delta):
	position.x += direction * delta * speed_x

func stomped(playerPosition : Vector2):
	get_tree().get_first_node_in_group("level_manager").on_score_get(100, area_2d.global_position)
	SoundManager.kick.play()
	if (in_shell):
		if (speed_x == 0):
			launch(playerPosition)
		else:
			speed_x = 0
	else:
		toShell()

func launch(playerPosition : Vector2):
	direction = -1 if playerPosition.x > global_position.x else 1
	speed_x = SHELL_SPEED

func toShell():
	update_collision_shape(KOOPA_SHELL_COLLISION_SHAPE, KOOPA_SHELL_COLLISION_SHAPE_POSITION)
	animated_sprite_2d.play("shell")
	speed_x = 0
	velocity.y = STOMP_VELOCITY_Y
	in_shell = true
	area_2d.set_collision_mask_value(3, true)

func backToNormal():
	velocity.y = STOMP_VELOCITY_Y
	update_collision_shape(KOOPA_NORMAL_COLLISION_SHAPE, KOOPA_NORMAL_COLLISION_SHAPE_POSITON)
	animated_sprite_2d.play("walk")
	speed_x = DEFAULT_SPEED_X
	in_shell = false
	area_2d.set_collision_mask_value(3, false)

func is_reachable():
	return in_shell && speed_x == 0

func _on_area_2d_area_entered(area):
	if speed_x != 0:
		if area.get_parent() is Enemy:
			area.get_parent().killed(position)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	set_physics_process(true)
