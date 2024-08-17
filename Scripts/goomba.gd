extends Enemy

class_name Goomba

const GOOMBA_FLAT_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const GOOMBA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")

func _physics_process(delta):
	basic_move(delta)
	move(delta)
	move_and_slide()

func move(delta):
	position.x += direction * delta * speed_x

func stomped(_playerPosition : Vector2):
	speed_x = 0
	update_collision_shape(GOOMBA_FLAT_COLLISION_SHAPE, Vector2(0, -3))
	animated_sprite_2d.play("death")
	death()
	SpawnUtils.spawn_text_label(area_2d.global_position, 100)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
