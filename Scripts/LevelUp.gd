extends Bonus

class_name LevelUp

@export var speed_x = 20
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
var type = LEVELUP_TYPE.MUSHROOM

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
