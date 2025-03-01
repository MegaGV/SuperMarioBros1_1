extends Area2D

class_name FireBall

@onready var ray_cast_2d = $RayCast2D

var speed_y = 100
var speed_x = 200
var amplitude = 20
var moving_up = false
var direction = 1
var order_change_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
    add_to_group("fireballs")

func _exit_tree():
    remove_from_group("fireballs")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if ray_cast_2d.is_colliding():
        moving_up = true
        order_change_pos = position
    if moving_up:
        if order_change_pos.y - amplitude >= position.y:
            moving_up = false
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
