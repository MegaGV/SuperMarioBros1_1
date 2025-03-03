extends Area2D

class_name Flag

# 旗帜
# 终点旗帜,因为旗杆不用动所以只有旗帜(

@onready var sprite_2d = $Sprite2D

func flag_up(pos: Vector2): # flag height 128
    # 根据摸到的高度决定得分
    var score = 100
    var height = global_position.y - pos.y
    if height > 120:
        score = 5000
    elif height > 64:
        score = 2000
    elif height > 32:
        score = 400
    
    # 旗杆底部生成分数并向上移动
    SpawnUtils.spawn_text_label(global_position + Vector2(16,0),score, Vector2(0, -112), 1, false)
    get_tree().get_first_node_in_group("level_manager").on_score_get(score)
    
    # 旗帜向下移动
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", global_position + Vector2(0,112), 1)
