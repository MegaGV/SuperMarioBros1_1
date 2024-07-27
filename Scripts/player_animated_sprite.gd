extends AnimatedSprite2D

class_name PlayerAnimatedSprite

func trigger_animation(velocity: Vector2, direction: int, player_mode: Player.PlayerMode):
	var mode = Player.PlayerMode.keys()[player_mode].to_snake_case()
	
	if direction != 0 && direction != sign(scale.x):
		scale.x = direction
	
	if not get_parent().is_on_floor():
		play("%s_jump" % mode)
	elif sign(velocity.x) != direction && abs(velocity.x) > 30 && direction != 0:
		play("%s_slide" % mode)
	elif (velocity.x != 0):
		play("%s_run" % mode)
	else:
		play("%s_idle" % mode)
		
	

