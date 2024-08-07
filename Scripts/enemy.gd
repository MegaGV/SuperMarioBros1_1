extends CharacterBody2D

class_name Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const DEFAULT_X_SPEED = 20
const KILL_Y_VELOCITY = -200

@export var speed_x = 20
@export var speed_y = 0
@export var direction = -1

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var area_2d = $Area2D as Area2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D

func _ready():
	speed_x = DEFAULT_X_SPEED

func _process(delta):
	pass

func stomped(playerPosition : Vector2):
	pass

func basic_move(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_wall():
		direction = -direction
		scale.x = -scale.x

func killed(killerPosition: Vector2):
	if (killerPosition.x >= position.x):
		direction = -1
	else:
		direction = 1
	velocity.y = KILL_Y_VELOCITY
	set_collision_mask_value(2, false)
	animated_sprite_2d.stop()
	scale.y = -scale.y
	death()
	ScoreUtils.spawn_points_label(area_2d, 100)

func death():
	set_collision_layer_value(3, false)
	area_2d.set_collision_layer_value(3, false)
	get_tree().create_timer(1).timeout.connect(queue_free)
	
func update_collision_shape(shape, position):
	body_collision_shape_2d.set_deferred("position", position)
	body_collision_shape_2d.set_deferred("shape", shape)
	area_collision_shape_2d.set_deferred("position", position)
	area_collision_shape_2d.set_deferred("shape", shape)
