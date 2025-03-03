extends Enemy

class_name Koopa

# 库巴兵

const KOOPA_SHELL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_shell_collision_shape.tres")
const KOOPA_NORMAL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/koopa_normal_collision_shape.tres")
const KOOPA_SHELL_COLLISION_SHAPE_POSITION = Vector2(0, -6)
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

# 被踩变龟壳或弹射出去或截停
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

# 根据接触方向偏向决定发射方向
func launch(playerPosition : Vector2):
    direction = -1 if playerPosition.x > global_position.x else 1
    speed_x = SHELL_SPEED

# 变龟壳
func toShell():
    update_collision_shape(KOOPA_SHELL_COLLISION_SHAPE, KOOPA_SHELL_COLLISION_SHAPE_POSITION)
    animated_sprite_2d.play("shell")
    speed_x = 0
    velocity.y = STOMP_VELOCITY_Y
    in_shell = true
    area_2d.set_collision_mask_value(3, true)

# 原版变龟壳一定时间后会恢复，暂时没用上
func backToNormal():
    velocity.y = STOMP_VELOCITY_Y
    update_collision_shape(KOOPA_NORMAL_COLLISION_SHAPE, KOOPA_NORMAL_COLLISION_SHAPE_POSITON)
    animated_sprite_2d.play("walk")
    speed_x = DEFAULT_SPEED_X
    in_shell = false
    area_2d.set_collision_mask_value(3, false)

# 是否可接触
# 普通模式和龟壳发射模式下都视为不可接触
func is_reachable():
    return in_shell && speed_x == 0

# 发射模式下接触敌人也会kill敌人
func _on_area_2d_area_entered(area):
    if speed_x != 0:
        if area.get_parent() is Enemy:
            area.get_parent().killed(position)

func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
    set_physics_process(true)
