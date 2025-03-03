extends Node

# SpawnUtils - 已全局自动加载
# 生成工具

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const COIN_SCENE = preload("res://Scenes/coin.tscn")
const LEVEL_UP_SCENE = preload("res://Scenes/level_up.tscn")
const ONE_UP_SCENE = preload("res://Scenes/one_up.tscn")
const FIRE_BALL_SCENE = preload("res://Scenes/fire_ball.tscn")
const EXPLOSION_SCENE = preload("res://Scenes/explosion.tscn")

# 生成points_label
# @textPos      : 生成位置
# @text         : 文本内容
# @moveVec      : 动画移动量
# @duration     : 动画持续时间
# @is_temp      : 是否临时
func spawn_text_label(textPos: Vector2, text, moveVec: Vector2 = Vector2.ZERO, duration:int = -1,  is_temp: bool = true):
    var spawner = POINTS_LABEL_SCENE.instantiate()
    spawner.text = text if text is not int else str(text)
    spawner.position = textPos + Vector2(-20, -20)
    if moveVec != Vector2.ZERO:
        spawner.moveVec = moveVec
    if duration != -1:
        spawner.duration = duration
    if is_temp != true:
        spawner.is_temp = false
    get_tree().root.add_child(spawner)
    #emit_signal("points_scored", score)

# 生成金币
# @spawnPosition    : 生成位置
func spawn_coin(spawnPosition: Vector2):
    var spawner = COIN_SCENE.instantiate()
    spawner.position = spawnPosition
    spawner.spawned = true
    get_tree().root.add_child(spawner)

# 生成升级道具
# @spawnPosition    : 生成位置
# @player_mode      : 玩家大小
func spawn_level_up(spawnPosition: Vector2, player_mode: Player.PlayerMode):
    var spawner = LEVEL_UP_SCENE.instantiate()
    if !player_mode == Player.PlayerMode.SMALL:
        spawner.type = LevelUp.LEVELUP_TYPE.FLOWER
    spawner.position = spawnPosition
    get_tree().root.add_child(spawner)

# 生成奖命道具
# @spawnPosition    : 生成位置
func spawn_one_up(spawnPosition: Vector2):
    var spawner = ONE_UP_SCENE.instantiate()
    spawner.position = spawnPosition
    get_tree().root.add_child(spawner)


# 生成火球
# @spawnPosition    : 生成位置
# @direction        : 发射方向
func spawn_fire_ball(spawnPosition: Vector2, direction: int):
    var spawner = FIRE_BALL_SCENE.instantiate()
    # 火球上限3个
    var fire_ball_count = get_tree().get_nodes_in_group(spawner.group_name).size()
    if (fire_ball_count >= 3):
        return

    SoundManager.fireball.play()
    spawner.position = spawnPosition
    spawner.direction = direction
    get_tree().root.add_child(spawner)

# 生成爆炸效果
# @spawnPosition    : 生成位置
func spawn_explosion(spawnPosition: Vector2):
    var spawner = EXPLOSION_SCENE.instantiate()
    spawner.position = spawnPosition
    get_tree().root.add_child(spawner)
