extends Block

class_name Brick

# 普通的砖块
# 可被大Mario破坏、小Mario顶起

@onready var gpu_particles_2d = $GPUParticles2D
@onready var sprite_2d = $Sprite2D

func bump(player_mode: Player.PlayerMode):
    if player_mode == Player.PlayerMode.SMALL:
        bump_up()
    else:
        check_top()
        # 破坏效果，展示效果后先隐藏节点，效果结束后再移除
        gpu_particles_2d.emitting = true
        set_collision_layer_value(2, false)
        sprite_2d.visible = false
        SoundManager.breakblock.play()

func _on_gpu_particles_2d_finished():
    queue_free()
