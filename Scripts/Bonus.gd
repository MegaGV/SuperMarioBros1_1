extends Area2D

class_name Bonus

# 奖励道具
# 游戏中存在的供玩家获取的奖励道具

var spawning = true

# 获取奖励
func get_bonus():
    queue_free()

# 对应在砖块上被顶起的情况
func bump_up(_pos: Vector2):
    pass
    
func spawn_animation():
    var spawn_tween = get_tree().create_tween()
    spawn_tween.tween_property(self, "position", position + Vector2(0 ,-16), .4)
    spawn_tween.tween_callback(func() : spawning = false)
