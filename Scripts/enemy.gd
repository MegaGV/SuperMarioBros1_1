extends CharacterBody2D

class_name Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const SPEED_DEFAULT = 20

@export var speed_x = 20
@export var speed_y = 100
@export var direction = -1

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var area_2d = $Area2D as Area2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D

func _ready():
	# default spped_y will be the gravity
	speed_x = SPEED_DEFAULT
	speed_y = gravity

func _process(delta):
	pass

func stomped(playerPosition : Vector2):
	pass

func death():
	set_collision_layer_value(3, false)
	area_2d.set_collision_layer_value(3, false)
	get_tree().create_timer(1).timeout.connect(queue_free)
	
func update_collision_shape(shape, position):
	body_collision_shape_2d.set_deferred("position", position)
	body_collision_shape_2d.set_deferred("shape", shape)
	area_collision_shape_2d.set_deferred("position", position)
	area_collision_shape_2d.set_deferred("shape", shape)
