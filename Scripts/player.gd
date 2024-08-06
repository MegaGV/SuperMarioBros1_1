extends CharacterBody2D

class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SMALL,
	BIG,
	FIRE
}

#signal points_scored(points: int)

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
	animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	
	move_and_slide()


func _on_area_2d_area_entered(area):
	if area.get_parent().get_parent().name == "Enemies": # Area2D->Koopa->Enemies
		handle_enemy_collision(area)

func handle_enemy_collision(enemyArea: Area2D):
	# 计算两者的角度 rad_to_deg将弧度转换为度数,angle_to_point 函数计算从当前对象的位置到指定点的角度（弧度值）
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemyArea.global_position ))
	# 判断是否踩在怪头上，是则触发踩怪头的逻辑，否则死亡
	if angle_of_collision > MIN_STOMP_DEGREE && angle_of_collision < MAX_STOMP_DEGREE:
		enemyArea.get_parent().stomped(position)
		on_enemy_stomped()
	# 碰到壳状态的乌龟，龟壳发射
	elif enemyArea.get_parent().name == "Koopa" && enemyArea.get_parent().in_shell: 
		enemyArea.get_parent().launch(position)
	# 你已经死了
	else:
		death()

# 踩怪头，弹起来一点点
func on_enemy_stomped():
	velocity.y = STOMP_Y_VELOCITY

func death():
	print("you died")	
