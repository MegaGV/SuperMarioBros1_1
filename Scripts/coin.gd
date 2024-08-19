extends Bonus

class_name Coin

@export var spawned = false
@onready var animated_sprite_2d = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	if spawned:
		spawn()

func spawn():
	animated_sprite_2d.play("spawn")
	var coin_tween = get_tree().create_tween()
	coin_tween.tween_property(self, "position", position + Vector2(0 ,-40), .3)
	coin_tween.tween_callback(queue_free)
	get_tree().get_first_node_in_group("level_manager").on_coin_collected(global_position)

func bump_up(pos: Vector2):
	pass

func get_bonus():
	super.get_bonus()
	get_tree().get_first_node_in_group("level_manager").on_coin_collected()
