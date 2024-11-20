extends StaticBody2D

class_name Block

@onready var raycast_2d = $RayCast2D

func bump(player_mode: Player.PlayerMode):
    pass

func bump_up():
    # play bump up animation
    var bump_tween = get_tree().create_tween()
    bump_tween.tween_property(self, "position", position + Vector2(0, -5), .12)
    bump_tween.chain().tween_property(self, "position", position, .12)
    SoundManager.bump.play()
    check_top()

# RayCast2D 只能检测到与它相交的第一个碰撞体,导致如果有复数目标不会都触发 
func check_top():
    if raycast_2d.is_colliding() && raycast_2d.get_collider() is Enemy:
        raycast_2d.get_collider().killed(position)
    if raycast_2d.is_colliding() && raycast_2d.get_collider() is Bonus:
        raycast_2d.get_collider().bump_up(get_tree().get_first_node_in_group("player").position)
