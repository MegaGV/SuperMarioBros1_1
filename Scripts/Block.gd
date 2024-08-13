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
	check_enemy_top()

func check_enemy_top():
	# check enemy
	if raycast_2d.is_colliding() && raycast_2d.get_collider() is Enemy:
		raycast_2d.get_collider().killed(position)
