extends AnimatedSprite2D

class_name PlayerAnimatedSprite

func trigger_animation(velocity: Vector2, direction: int, player_mode: Player.PlayerMode):
	var animation_prefix = Player.PlayerMode.keys()[player_mode].to_snake_case()
	
	if not get_parent().is_on_floor():
		play("%s_jump" % animation_prefix)
	

