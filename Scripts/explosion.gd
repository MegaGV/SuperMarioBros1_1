extends Node2D

# 爆炸效果
# 计划用于火球接触目标、通关结算烟花使用

func _on_animated_sprite_2d_animation_finished():
    queue_free()
