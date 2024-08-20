extends Bonus

class_name LevelUp

@export var speed_x = 30
@export var speed_y = 0
@export var speed_y_max = 120
@export var velocity_y = .1

@onready var shape_cast_2d_y = $ShapeCast2D
@onready var shape_cast_2d_x = $ShapeCast2D2
@onready var animated_sprite_2d = $AnimatedSprite2D
enum LEVELUP_TYPE {
	MUSHROOM,
	FLOWER
}

var spawned = true
@export var type = LEVELUP_TYPE.MUSHROOM

# Called when the node enters the scene tree for the first time.
func _ready():
	if type == LEVELUP_TYPE.FLOWER:
		animated_sprite_2d.play("flower")
	var mushroom_tween = get_tree().create_tween()
	mushroom_tween.tween_property(self, "position", position + Vector2(0 ,-16), .4)
	mushroom_tween.tween_callback(func() : spawned = false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if type == LEVELUP_TYPE.MUSHROOM && !spawned:
		if !shape_cast_2d_y.is_colliding():
			speed_y = lerpf(speed_y, speed_y_max, velocity_y)
			position.y += speed_y * delta
		else:
			speed_y = 0
		if shape_cast_2d_x.is_colliding():
			speed_x = -speed_x
			shape_cast_2d_x.target_position.x = -shape_cast_2d_x.target_position.x
		position.x += speed_x * delta

func bump_up(pos: Vector2):
	var bump_tween = get_tree().create_tween()
	if pos.x < global_position.x:
		bump_tween.tween_property(self, "position", position + Vector2(10, -20), .2)
		speed_x = abs(speed_x)
	else:
		bump_tween.tween_property(self, "position", position + Vector2(-10, -20), .2)
		speed_x = -abs(speed_x)

func get_bonus():
	super.get_bonus()
	get_tree().get_first_node_in_group("player").level_up(true)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
