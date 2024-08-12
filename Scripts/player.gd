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
@onready var area_2d = $Area2D
#@onready var ray_cast_2d = $RayCast2D

@export_group("Locomotion")
@export var RUN_SPEED_DAMPING = 0.8
@export var SPEED = 150.0
@export var SPEED_HIGH = 250.0
@export var JUMP_VELOCITY = -350
@export_group("")

@export_group("Stomping enemies")
@export var MIN_STOMP_DEGREE = 35
@export var MAX_STOMP_DEGREE = 145
@export var STOMP_Y_VELOCITY = -200
@export_group("")

var player_mode = PlayerMode.SMALL
var is_dead = false

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
	# 兼容键盘和手柄的方案
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction:
		# 使用线性插值让速度逐步上升
		if (Input.is_action_pressed("action")):
			velocity.x = lerpf(velocity.x, SPEED_HIGH * direction, RUN_SPEED_DAMPING * delta)
		else:
			velocity.x = lerpf(velocity.x, SPEED * direction, RUN_SPEED_DAMPING * delta)
	else:
		# 速度缓慢变化模拟移动惯性
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	# play animaiton
	animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	
	#if ray_cast_2d.is_colliding():
		#var collider = $RayCast2D.get_collider()
		#if collider is TileMap:
			#var tilemap = collider as TileMap
			#var tile_location = $RayCast2D.get_collision_point()
			#var tile_location2 = tilemap.local_to_map(tile_location)
			#tile_location2.y -= 1
			#var tile_data = tilemap.get_cell_tile_data(0, tile_location2)
			#if tile_data:
				#print(tile_data.get_custom_data("can_be_bumped"))
			#print(tile_location,tile_location2)

	#get_node("../TileMap").set_cell(0, Vector2(16,8),0,Vector2(4,1))
	
	move_and_slide()

func _on_area_2d_area_entered(area):
	if is_dead:
		return
	if area.get_parent() is Enemy: # Area2D->Koopa
		handle_enemy_collision(area)

func handle_enemy_collision(enemyArea: Area2D):
	# 计算两者的角度 rad_to_deg将弧度转换为度数,angle_to_point 函数计算从当前对象的位置到指定点的角度（弧度值）
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemyArea.global_position ))
	
	# 判断是否踩在怪头上，是则触发踩怪头的逻辑，否则死亡
	var enemy = enemyArea.get_parent()
	if angle_of_collision > MIN_STOMP_DEGREE && angle_of_collision < MAX_STOMP_DEGREE:
		enemy.stomped(position)
		on_enemy_stomped()
	# 碰到静止的壳状态的乌龟，龟壳发射
	elif enemy is Koopa && enemy.is_reachable(): 
		enemy.launch(position)
	else:
		affected()

# 踩怪头，弹起来一点点
func on_enemy_stomped():
	velocity.y = STOMP_Y_VELOCITY

func affected():
	print("you died")
	if player_mode == PlayerMode.BIG:
		pass
	elif player_mode == PlayerMode.FIRE:
		pass
	else: # small
		is_dead = true
		animated_sprite_2d.play("death")
		set_physics_process(false)
		area_2d.set_collision_layer_value(1, false)
		
		# play death move
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -50), 0.5)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1)
		# after death reset game
		death_tween.tween_callback(func (): get_tree().reload_current_scene())
