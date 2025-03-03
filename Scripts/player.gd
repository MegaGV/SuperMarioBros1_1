extends CharacterBody2D

class_name Player

# 玩家

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
    get_tree().get_first_node_in_group("level_manager").timer.start()
    # 非初始状态下的数据继承
    if SceneData.player_mode != null:
        player_mode = SceneData.player_mode
    # 从管道出来情况下的登场动画
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
    
    if is_controllable:
        # 跳跃
        if Input.is_action_just_pressed("jump") and is_on_floor(): # 地面
            SoundManager.jump.play()
            velocity.y = JUMP_VELOCITY
        if Input.is_action_just_released("jump") and velocity.y < 0: # 空中松开跳跃键
            velocity.y *= 0.5
        
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
        
        # 如果身处传送区域,按下对应方向键进入
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
            
        # 蹲下和站起时需及时更新判定区域
        if is_squat:
            update_collision_shape(BIG_SQUAT_COLLISION_SHAPE, Vector2(0,4))
            velocity.x = move_toward(velocity.x, 0, SPEED * delta)
        elif player_mode != PlayerMode.SMALL:
            update_collision_shape(BIG_COLLISION_SHAPE, Vector2.ZERO)
        
        if is_fire:
            shoot()
    
        # 限制回头路
        if global_position.x < camera_left_bound + 8 && sign(velocity.x) == -1:
            velocity.x = 0
        
        # 处理碰撞,基本上是顶砖块
        handle_movement_collision(get_last_slide_collision())

    # 更新精灵
    animated_sprite_2d.trigger_animation(velocity, direction, is_squat, is_fire, player_mode)

    # 罗伯特~
    if position.y > 300:
        death()
    
    move_and_slide()

func _process(_delta):
    # 更新相机位置
    if (should_camera_sync && global_position.x > camera_sync.global_position.x):
        camera_sync.global_position.x = global_position.x
        camera_left_bound = camera_sync.global_position.x - camera_sync.get_viewport_rect().size.x / 2 / camera_sync.zoom.x

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
    if area is TransportArea: # 离开传送区域，清除传送方向
        transport_direction = TransportArea.ENTER_DIRECTION.NONE

# 敌人碰撞处理
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
    if collison.get_collider() is Block: # 如果在方块正下方，触发顶方块
        var angle_of_collision = rad_to_deg(collison.get_angle())
        if roundf(angle_of_collision) == 180:
            collison.get_collider().bump(player_mode)

# 升级还是降级，这是个问题
func level_up(upgrade: bool):
    if upgrade:
        if player_mode == PlayerMode.SMALL:
            freeze(false)
            player_mode = PlayerMode.BIG
            animated_sprite_2d.play("small_to_big")
            SoundManager.levelup.play()
        elif player_mode == PlayerMode.BIG:
            freeze(false)
            player_mode = PlayerMode.FIRE
            animated_sprite_2d.play("big_to_fire")
            SoundManager.levelup.play()
        else:
            get_tree().get_first_node_in_group("level_manager").on_score_get(100, position)
    else:
        SoundManager.effect.play()
        freeze(false)
        var before = player_mode
        player_mode = PlayerMode.SMALL
        animated_sprite_2d.play("big_to_small" if before == PlayerMode.BIG else "fire_to_small")
    update_collision_shape(SMALL_COLLISION_SHAPE if player_mode == PlayerMode.SMALL else BIG_COLLISION_SHAPE, Vector2.ZERO)

# 受击
func affected():
    if player_mode == PlayerMode.SMALL:
        death()
    else:
        level_up(false)

func death():
        is_dead = true
        animated_sprite_2d.play("death")
        set_physics_process(false)
        MusicManager.changeMusic("death")
        get_tree().get_first_node_in_group("level_manager").timer.stop()
        # play death move
        var death_tween = get_tree().create_tween()
        death_tween.tween_property(self, "position", position + Vector2(0, -50), 0.5)
        death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1)
        # after death reset game
        await get_tree().create_timer(3).timeout
        SceneData.start_point = Vector2.ZERO
        SceneData.player_mode = PlayerMode.SMALL
        get_tree().reload_current_scene()

# 射击
# 反向时，射击点位置也要反向
func shoot():
    var direction = animated_sprite_2d.scale.x
    var pos = shooting_point.global_position
    if direction == -1:
        pos.x -= shooting_point.position.x * 2
    SpawnUtils.spawn_fire_ball(pos, direction)

# 玩家不可操作时的冻结复合项
func freeze(enable: bool):
    set_physics_process(enable)
    set_collision_layer_value(1, enable)
    area_2d.set_collision_layer_value(1, enable)
    z_index = 1 if enable else 0

# 更新判定
func update_collision_shape(newShape,newPos):
    body_collision_shape_2d.set_deferred("shape", newShape)
    area_collision_shape_2d.set_deferred("shape", newShape)
    if newPos != null:
        body_collision_shape_2d.set_deferred("position", newPos)
        area_collision_shape_2d.set_deferred("position", newPos)

# 传送
# 根据方向播放对应方向的进管道动画
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
    SoundManager.effect.play()
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", position + leave_direction, .5)
    tween.tween_callback(func (): get_tree().get_first_node_in_group("level_manager").switch_scene(self))

# 爬旗杆动画part1 从旗杆上滑下
func climb_flag(area: Flag):
    get_tree().get_first_node_in_group("level_manager").timer.stop()
    MusicManager.changeMusic("flagpole")
    freeze(false)
    is_controllable = false
    animated_sprite_2d.play("%s_climb" % Player.PlayerMode.keys()[player_mode].to_snake_case())
    var tween = get_tree().create_tween()
    var bottom_y = 192-8 if player_mode == PlayerMode.SMALL else 192-16
    area.flag_up(position)
    tween.tween_property(self, "position", position + Vector2(0,bottom_y - position.y), 1)
    tween.tween_callback(func (): climb_flag2())

# 爬旗杆动画part2 走向城堡
func climb_flag2():
    MusicManager.changeMusic("castle")
    position.x += 16
    scale.x = -1
    await get_tree().create_timer(0.3).timeout
    freeze(true)
    velocity.x = 60
    scale.x = 1

# 通关
func clear():
    freeze(false)
    animated_sprite_2d.visible = false
    get_tree().get_first_node_in_group("level_manager").clear()
    get_tree().get_first_node_in_group("level_manager").timer.start()
