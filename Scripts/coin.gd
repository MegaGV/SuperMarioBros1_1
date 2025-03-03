extends Bonus

class_name Coin

# 金币
# 游戏中有两种金币，一种是拾取的，一种是问号箱子生成的，通过spawned区分

@export var spawned = false
@onready var animated_sprite_2d = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
    if spawned:
        spawn()

# 生成金币，对应问号箱子里冒出的金币
# 播放金币生成动画，随后直接触发level_manager的金币拾取事件
func spawn():
    animated_sprite_2d.play("spawn")
    var coin_tween = get_tree().create_tween()
    coin_tween.tween_property(self, "position", position + Vector2(0 ,-40), .3)
    coin_tween.tween_callback(queue_free)
    get_tree().get_first_node_in_group("level_manager").on_coin_collected(global_position)

# 顶起金币，直接获取并弹出得分
func bump_up(_pos: Vector2):
    get_tree().get_first_node_in_group("level_manager").on_score_get(100, global_position)
    get_bonus()

func get_bonus():
    super.get_bonus()
    get_tree().get_first_node_in_group("level_manager").on_coin_collected()
