extends Block

class_name Brick

func bump(player_mode: Player.PlayerMode):
	if player_mode == Player.PlayerMode.SMALL:
		bump_up()
	else:
		# animation to do
		queue_free()
