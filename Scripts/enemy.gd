extends CharacterBody2D

class_name Enemy

# 敌人

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const DEFAULT_SPEED_X = 20
const KILL_VELOCITY_Y = -200

@export var speed_x = DEFAULT_SPEED_X
@export var speed_y = 0
@export var direction = -1

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var area_2d = $Area2D as Area2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D

# 默认不行动，玩家进入一定范围后再行动
func _ready():
    set_physics_process(false)

func _process(_delta):
    pass

# 被踩的反馈，根据敌人种类实现
func stomped(_playerPosition : Vector2):
    pass

# 基础移动逻辑,牛顿下落和碰壁回头
func basic_move(delta):
    if not is_on_floor():
        velocity.y += gravity * delta
    if is_on_wall():
        direction = -direction
        scale.x = -scale.x

# 被干掉基础逻辑，注意区别于被踩死，两者属于不同的退场方式
# 播放死亡动画，生成得分
# 攻击x方向->死亡动画偏移;y方向默认向下坠落
func killed(killerPosition: Vector2):
    direction = -1 if killerPosition.x >= position.x else 1
    velocity.y = KILL_VELOCITY_Y
    set_collision_mask_value(2, false)
    animated_sprite_2d.stop()
    scale.y = -scale.y
    death()
    get_tree().get_first_node_in_group("level_manager").on_score_get(100, area_2d.global_position)

# 被干掉后清理逻辑
# 去除判定，延时清理
func death():
    set_collision_layer_value(3, false)
    area_2d.set_collision_layer_value(3, false)
    get_tree().create_timer(1).timeout.connect(queue_free)

# 更新判定
# 部分敌人的判定区会发生变化，如乌龟变龟壳
func update_collision_shape(newShape, newPosition):
    body_collision_shape_2d.set_deferred("position", newPosition)
    body_collision_shape_2d.set_deferred("shape", newShape)
    area_collision_shape_2d.set_deferred("position", newPosition)
    area_collision_shape_2d.set_deferred("shape", newShape)
