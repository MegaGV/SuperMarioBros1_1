extends Area2D

class_name FireBall

# 火球
# 可由火焰马里奥发射的子弹

@onready var ray_cast_2d = $RayCast2D

var speed_y = 100
var speed_x = 200
var amplitude = 20 # 上下摆动幅度
var moving_up = false
var direction = 1
var order_change_pos = Vector2.ZERO
var group_name = "fireballs" # 通过组来计数以控制火球数量

# Called when the node enters the scene tree for the first time.
func _ready():
    add_to_group(group_name)

func _exit_tree():
    remove_from_group(group_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # 即将接触地面,转为向上移动，记录此时地面高度，控制向上移动距离在幅度内
    if ray_cast_2d.is_colliding():
        moving_up = true
        order_change_pos = position
    # 向上移动达到幅度后，重新向下移动。因为马里奥里不存在半格图块,所以不用担心向上过程中穿模
    if moving_up:
        if order_change_pos.y - amplitude >= position.y:
            moving_up = false
    # start roll~
    position.x += delta * speed_x * direction
    position.y += delta * speed_y * 1 if !moving_up else -1


func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free()

func _on_area_entered(area):
    if area.get_parent() is Enemy:
        area.get_parent().killed(global_position)
    #SoundManager.firework.play()
    queue_free()

func _on_body_entered(_body):
    SpawnUtils.spawn_explosion(global_position)
    #SoundManager.firework.play()
    queue_free()
