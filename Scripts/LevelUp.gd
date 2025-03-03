extends Bonus

class_name LevelUp

# 升级道具
# 即红蘑菇和火焰花，出现时是蘑菇还是花取决于是马里奥的大小，且效果均为升一级。小玛丽奥吃火焰花也只会变成大马里奥

@export var speed_x = 30
@export var speed_y = 0
@export var speed_y_max = 120
@export var velocity_y = .1

@onready var shape_cast_2d_y = $ShapeCast2D
@onready var shape_cast_2d_x = $ShapeCast2D2
@onready var animated_sprite_2d = $AnimatedSprite2D
enum LEVELUP_TYPE {
    MUSHROOM,
    FLOWER
}

@export var type = LEVELUP_TYPE.MUSHROOM

# Called when the node enters the scene tree for the first time.
func _ready():
    if type == LEVELUP_TYPE.FLOWER:
        animated_sprite_2d.play("flower")
    spawn_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # 这里用了两个shapeCast2D来模拟重力和左右碰壁移动，因为父类只是Area2D而不是CharacterBody2D
    # 但是其实可以参考enemy和player用更简单的方法，懒得改了
    if type == LEVELUP_TYPE.MUSHROOM && !spawning:
        if !shape_cast_2d_y.is_colliding():
            speed_y = lerpf(speed_y, speed_y_max, velocity_y)
            position.y += speed_y * delta
        else:
            speed_y = 0
        if shape_cast_2d_x.is_colliding():
            speed_x = -speed_x
            shape_cast_2d_x.target_position.x = -shape_cast_2d_x.target_position.x
        position.x += speed_x * delta

# 被顶起
# 蘑菇被顶起会被顶飞甚至改变方向,但是花也不会出现被顶的情况，所以不用判断
func bump_up(pos: Vector2):
    var bump_tween = get_tree().create_tween()
    if pos.x < global_position.x:
        bump_tween.tween_property(self, "position", position + Vector2(10, -20), .2)
        speed_x = abs(speed_x)
    else:
        bump_tween.tween_property(self, "position", position + Vector2(-10, -20), .2)
        speed_x = -abs(speed_x)

func get_bonus():
    super.get_bonus()
    get_tree().get_first_node_in_group("player").level_up(true)


func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free()
