extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var player_position = get_node("../Player").global_position
	# 仅更新相机的 x 位置
	if (player_position.x > 130):
		global_position.x = player_position.x
