extends Enemy

class_name Goomba

# 栗宝宝

const GOOMBA_FLAT_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const GOOMBA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")

func _physics_process(delta):
    basic_move(delta)
    move(delta)
    move_and_slide()

func move(delta):
    position.x += direction * delta * speed_x

# 被踩扁平退场，非killed
func stomped(_playerPosition : Vector2):
    speed_x = 0
    update_collision_shape(GOOMBA_FLAT_COLLISION_SHAPE, Vector2(0, 0))
    animated_sprite_2d.play("death")
    death()
    SoundManager.stomp.play()
    get_tree().get_first_node_in_group("level_manager").on_score_get(100, area_2d.global_position)

func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
    set_physics_process(true)
