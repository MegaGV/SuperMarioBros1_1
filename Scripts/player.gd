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
@export var RUN_SPEED_DAMPING = 0.5
@export var SPEED = 200.0
@export var JUMP_VELOCITY = -350
@export_group("")

@export_group("Stomping enemies")
@export var MIN_STOMP_DEGREE = 35
@export var MAX_STOMP_DEGREE = 145
@export var STOMP_Y_VELOCITY = -200
@export_group("")

var player_mode = PlayerMode.SMALL

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor(): # groud
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and velocity.y < 0: # jumping and released
		velocity.y *= 0.5

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		# 使用线性插值让速度逐步上升
		velocity.x = lerpf(velocity.x, SPEED * direction, RUN_SPEED_DAMPING * delta)
	else:
		# 速度缓慢变化模拟移动惯性
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	# play animaiton
	if animated_sprite_2d != null:
		animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	else:
		print("Animator is not initialized!")
	
	move_and_slide()


func _on_area_2d_area_entered(area):
	if area.get_parent().get_parent().name == "Enemies": # Area2D->Koopa->Enemies
		handle_enemy_collision(area)

func handle_enemy_collision(enemyArea: Area2D):
	#var enemyName = enemyArea.get_parent().name
	#print("enemy: %s" % enemyName)
	
	# 计算两者的角度 rad_to_deg将弧度转换为度数,angle_to_point 函数计算从当前对象的位置到指定点的角度（弧度值）
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemyArea.global_position ))
	#print("(", enemyArea.global_position.x, ",", enemyArea.global_position .y, ")")
	#print("%s" % angle_of_collision)
	
	if angle_of_collision > MIN_STOMP_DEGREE && angle_of_collision < MAX_STOMP_DEGREE:
		enemyArea.get_parent().stomped(angle_of_collision)
		on_enemy_stomped()
	else:
		death()

func on_enemy_stomped():
	velocity.y = STOMP_Y_VELOCITY

func death():
	print("you died")	
