extends CharacterBody2D

class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const SMALL_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/mario_small_collision_shape.tres")
const BIG_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/mario_big_collision_shape.tres")
const BIG_SQUAT_COLLISION_SHAPE = preload("res://Resource/CollisionShapes/mario_big_squat_collision_shape.tres")

enum PlayerMode {
	SMALL,
	BIG,
	FIRE
}

#signal points_scored(points: int)

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_2d = $Area2D
@onready var shooting_point = $ShootingPoint

var RUN_SPEED_DAMPING = 1.2
var SPEED = 150.0
var SPEED_HIGH = 250.0
var JUMP_VELOCITY = -350
var MIN_STOMP_DEGREE = 35 #50
var MAX_STOMP_DEGREE = 145 #130
var STOMP_Y_VELOCITY = -200

@export_group("Camera")
@export var camera_sync: Camera2D
@export var should_camera_sync = true
@export_group("")

var player_mode = PlayerMode.SMALL
var is_dead = false
var is_controllable = true
var camera_left_bound : int = 0
var transport_to : Vector2 = Vector2.ZERO
var transport_direction : TransportArea.ENTER_DIRECTION = TransportArea.ENTER_DIRECTION.NONE
var transport_path : String = ""

func _ready():
	if SceneData.player_mode != null:
		player_mode = SceneData.player_mode
	if SceneData.start_point != Vector2.ZERO:
		freeze(false)
		var tween = get_tree().create_tween()
		position = SceneData.start_point
		position.y += 16
		animated_sprite_2d.play("%s_idle" % Player.PlayerMode.keys()[player_mode].to_snake_case())
		if player_mode == PlayerMode.SMALL:
			tween.tween_property(self, "position", position + Vector2(0,-24), .5)
		else:
			tween.tween_property(self, "position", position + Vector2(0,-32), .5)
		tween.tween_callback(func (): freeze(true))
		

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var is_squat = 0 
	var is_fire  = false
	var direction = 1
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor(): # groud
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and velocity.y < 0: # jumping and released
		velocity.y *= 0.5
	
	if is_controllable:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		# 兼容键盘和手柄的方案
		is_squat = Input.get_action_strength("down") == 1 && player_mode != Player.PlayerMode.SMALL
		is_fire = Input.is_action_just_pressed("action") && player_mode == Player.PlayerMode.FIRE
		direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		if direction:
			# 使用线性插值让速度逐步上升
			if (Input.is_action_pressed("action")):
				velocity.x = lerpf(velocity.x, SPEED_HIGH * direction, RUN_SPEED_DAMPING * delta)
			else:
				velocity.x = lerpf(velocity.x, SPEED * direction, RUN_SPEED_DAMPING * delta)
		else:
			# 速度缓慢变化模拟移动惯性
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		
		if (transport_direction != TransportArea.ENTER_DIRECTION.NONE):
			match transport_direction:
				TransportArea.ENTER_DIRECTION.DOWN:
					if is_on_floor() && Input.get_action_strength("down") == 1:
						transport()
				TransportArea.ENTER_DIRECTION.RIGHT:
					if is_on_floor() && direction == 1:
						transport()
				TransportArea.ENTER_DIRECTION.UP:
					if !is_on_floor() && Input.get_action_strength("up") == 1:
						transport()
				TransportArea.ENTER_DIRECTION.LEFT:
					if is_on_floor() && direction == -1:
						transport()
			
		if is_squat:
			update_collision_shape(BIG_SQUAT_COLLISION_SHAPE, Vector2(0,4))
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		elif player_mode != PlayerMode.SMALL:
			update_collision_shape(BIG_COLLISION_SHAPE, Vector2.ZERO)
		if is_fire:
			shoot()
	
	# camera move
	camera_left_bound = camera_sync.global_position.x - camera_sync.get_viewport_rect().size.x / 2 / camera_sync.zoom.x
	if global_position.x < camera_left_bound + 8 && sign(velocity.x) == -1:
		velocity.x = 0
	
	# play animaiton
	animated_sprite_2d.trigger_animation(velocity, direction, is_squat, is_fire, player_mode)
	
	handle_movement_collision(get_last_slide_collision())	
	
	if position.y > 250:
		death()
	
	move_and_slide()

func _process(delta):
	# 更新相机位置
	if (should_camera_sync && global_position.x > camera_sync.global_position.x):
		camera_sync.global_position.x = global_position.x


func _on_area_2d_area_entered(area):
	if is_dead:
		return
	if area.get_parent() is Enemy:
		handle_enemy_collision(area)
	elif area is Bonus:
		area.get_bonus()
	elif area is TransportArea:
		if area.transportCheck(position):
			transport_to = area.exitPos
			transport_direction = area.enterDirection
			transport_path = area.exitScenePath
	elif area is Flag:
		climb_flag(area)
	elif area is Castle:
		clear()

func _on_area_2d_area_exited(area):
	if area is TransportArea:
		transport_direction = TransportArea.ENTER_DIRECTION.NONE

func handle_enemy_collision(enemyArea: Area2D):
	# 计算两者的角度 rad_to_deg将弧度转换为度数,angle_to_point 函数计算从当前对象的位置到指定点的角度（弧度值）
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemyArea.global_position ))
	
	# 判断是否踩在怪头上，是则触发踩怪头的逻辑，否则死亡
	var enemy = enemyArea.get_parent()
	if angle_of_collision > MIN_STOMP_DEGREE && angle_of_collision < MAX_STOMP_DEGREE:
		enemy.stomped(position)
		velocity.y = STOMP_Y_VELOCITY
	# 碰到静止的壳状态的乌龟，龟壳发射
	elif enemy is Koopa && enemy.is_reachable(): 
		get_tree().get_first_node_in_group("level_manager").on_score_get(100, position)
		enemy.launch(position)
	else:
		affected()

func handle_movement_collision(collison: KinematicCollision2D):
	if collison == null:
		return
	if collison.get_collider() is Block:
		var angle_of_collision = rad_to_deg(collison.get_angle())
		if roundf(angle_of_collision) == 180:
			collison.get_collider().bump(player_mode)

func level_up(upgrade: bool):
	if upgrade:
		if player_mode == PlayerMode.SMALL:
			freeze(false)
			player_mode = PlayerMode.BIG
			animated_sprite_2d.play("small_to_big")
		elif player_mode == PlayerMode.BIG:
			freeze(false)
			player_mode = PlayerMode.FIRE
			animated_sprite_2d.play("big_to_fire")
		else:
			get_tree().get_first_node_in_group("level_manager").on_score_get(100, position)
	else:
		freeze(false)
		var before = player_mode
		player_mode = PlayerMode.SMALL
		animated_sprite_2d.play("big_to_small" if before == PlayerMode.BIG else "fire_to_small")
	update_collision_shape(SMALL_COLLISION_SHAPE if player_mode == PlayerMode.SMALL else BIG_COLLISION_SHAPE, Vector2.ZERO)

func affected():
	if player_mode == PlayerMode.SMALL:
		death()
	else:
		level_up(false)

func death():
		is_dead = true
		animated_sprite_2d.play("death")
		set_physics_process(false)
		# play death move
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -50), 0.5)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1)
		# after death reset game
		death_tween.tween_callback(func (): get_tree().reload_current_scene())

func shoot():
	var direction = animated_sprite_2d.scale.x
	var pos = shooting_point.global_position
	if direction == -1:
		pos.x -= shooting_point.position.x * 2
	SpawnUtils.spawn_fire_ball(pos, direction)

func freeze(enable: bool):
	set_physics_process(enable)
	set_collision_layer_value(1, enable)
	area_2d.set_collision_layer_value(1, enable)
	z_index = 1 if enable else 0

func update_collision_shape(newShape,newPos):
	body_collision_shape_2d.set_deferred("shape", newShape)
	area_collision_shape_2d.set_deferred("shape", newShape)
	if newPos != null:
		body_collision_shape_2d.set_deferred("position", newPos)
		area_collision_shape_2d.set_deferred("position", newPos)

func transport():
	freeze(false)
	var leave_direction = Vector2.ZERO
	match transport_direction:
		TransportArea.ENTER_DIRECTION.DOWN:
			leave_direction = Vector2(0,36)
		TransportArea.ENTER_DIRECTION.RIGHT:
			leave_direction = Vector2(36,0)
		TransportArea.ENTER_DIRECTION.UP:
			leave_direction = Vector2(0,-36)
		TransportArea.ENTER_DIRECTION.LEFT:
			leave_direction = Vector2(-36,0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + leave_direction, .5)
	tween.tween_callback(func (): get_tree().get_first_node_in_group("level_manager").switch_scene(self))

func climb_flag(area: Flag):
	freeze(false)
	is_controllable = false
	animated_sprite_2d.play("%s_climb" % Player.PlayerMode.keys()[player_mode].to_snake_case())
	var tween = get_tree().create_tween()
	var bottom_y = 192-8 if player_mode == PlayerMode.SMALL else 192-16
	area.flag_up(position)
	tween.tween_property(self, "position", position + Vector2(0,bottom_y - position.y), 1)
	tween.tween_callback(func (): climb_flag2())

func climb_flag2():
	position.x += 16
	scale.x = -1
	await get_tree().create_timer(0.3).timeout
	freeze(true)
	velocity.x = 60
	scale.x = 1

func clear():
	freeze(false)
	animated_sprite_2d.visible = false
