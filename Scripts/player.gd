extends CharacterBody2D

class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SMALL,
	BIG,
	FIRE
}

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape = $BodyCollisionShape2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200.0
@export var jump_velocity = -350
@export_group("")

var player_mode = PlayerMode.SMALL

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor(): # groud
		velocity.y = jump_velocity
	if Input.is_action_just_released("jump") and velocity.y < 0: # jumping and released
		velocity.y *= 0.5
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		#velocity.x = direction * speed
		velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		velocity.x = move_toward(velocity.x, 0, speed * delta)

	# play animaiton
	if animated_sprite_2d != null:
		animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	else:
		print("Animator is not initialized!")
	

	move_and_slide()
