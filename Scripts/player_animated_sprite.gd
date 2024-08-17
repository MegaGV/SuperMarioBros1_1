extends AnimatedSprite2D

class_name PlayerAnimatedSprite

var shoot_complete = true

func trigger_animation(velocity: Vector2, direction: int, squat: bool, fire: bool, player_mode: Player.PlayerMode):
	var mode = Player.PlayerMode.keys()[player_mode].to_snake_case()
	
	offset = Vector2.ZERO
	
	if direction != 0 && direction != sign(scale.x):
		scale.x = direction
	
	if !shoot_complete:
		return
	
	if not get_parent().is_on_floor():
		play("%s_jump" % mode)
	elif sign(velocity.x) != direction && abs(velocity.x) > 30 && direction != 0:
		play("%s_slide" % mode)
	elif fire:
		play("shoot")
		shoot_complete = false
	elif squat:
		play("%s_squat" % mode)
		offset = Vector2(0,4)
	elif (velocity.x != 0):
		play("%s_run" % mode)
	else:
		play("%s_idle" % mode)
		

func _on_animation_finished():
	if animation.contains("to"):
		reset_player_properties()
	elif animation == "shoot":
		shoot_complete = true

func reset_player_properties():
	offset = Vector2.ZERO
	get_parent().set_physics_process(true)
	get_parent().set_collision_layer_value(1, true)
	get_parent().area_2d.set_collision_layer_value(1, true)


func _on_frame_changed():
	if animation == "small_to_big":
		var mode = get_parent().player_mode
		if (frame % 2):
			offset = Vector2(0, 0 if mode == Player.PlayerMode.SMALL else -8)
		else:
			offset = Vector2(0, 0 if mode != Player.PlayerMode.SMALL else -8)
	elif animation.contains("to_small"):
		if (frame % 2):
			offset = Vector2(0,8)
		else:
			offset = Vector2(0,0)

