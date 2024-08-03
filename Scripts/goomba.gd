extends Enemy

const GOOMBA_FLAT_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const GOOMBA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")
const GOOMBA_FLAT_COLLISION_SHAPE_POSITION = Vector2(0, -3)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	walk(delta)
	move_and_slide()

func walk(delta):
	position.x += direction * delta * speed_x

func stomped(angle_of_collision : float):
	death()

func death():
	super.death()
	speed_x = 0
	speed_y = 0
	update_collision_shape(GOOMBA_FLAT_COLLISION_SHAPE, GOOMBA_FLAT_COLLISION_SHAPE_POSITION)
	animated_sprite_2d.play("death")
