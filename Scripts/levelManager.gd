extends Node

class_name LevelManager

# LevelManager
# 关卡管理器，没设置成全局，导致每个Scene都有自己的管理器和UI和Timer
# 但是懒得改了

var score = 0
var coin = 0
var time = 400
var is_clear = false

@export var ui: MarioUI
@export var timer: Timer

# 场景开始,继承并更新UI信息
func _ready():
    timer.start()
    timer.timeout.connect(self._on_timer_timeout)
    if SceneData.coin != -1:
        coin = SceneData.coin
        ui.update_coin(coin)
    if SceneData.score != -1:
        score = SceneData.score
        ui.update_score(score)
    if SceneData.time != -1:
        time = SceneData.time
        ui.update_time(time)
    MusicManager.changeMusic(get_parent().name, time)

# 收集金币
# 处理得分、计算奖命、生成标签、更新UI
func on_coin_collected(pos: Vector2 = Vector2.ZERO):
    SoundManager.coin.play()
    coin += 1
    if coin > 99:
        coin = 0
        on_get_extra_life()
    if pos != Vector2.ZERO:
        SpawnUtils.spawn_text_label(pos, 200)
    ui.update_coin(coin)
    on_score_get(200)

# 处理得分
# 计算得分、生成标签、更新UI
func on_score_get(scoreGet: int, pos: Vector2 = Vector2.ZERO):
    score += scoreGet
    if pos != Vector2.ZERO:
        SpawnUtils.spawn_text_label(pos, scoreGet)
    ui.update_score(score)

# 奖命
# 但是很遗憾压根没有剩余生命一说
func on_get_extra_life():
    SpawnUtils.spawn_text_label(get_node("../Player").position, "1UP")
    SoundManager.oneup.play()

# 切换场景
# 保存数据到SceneData
func switch_scene(player: Player):
    get_tree().change_scene_to_file(player.transport_path)
    SceneData.player_mode = player.player_mode
    SceneData.start_point = player.transport_to
    SceneData.coin = coin
    SceneData.score = score
    SceneData.time = time
    timer.stop()

# 计时器
# 实时更新时间、通关时间结算、时间紧迫提示、时间结束死亡
func _on_timer_timeout():
    time -= 1
    ui.update_time(time)
    if is_clear:
        on_score_get(50)
        SoundManager.coinRepeat()
    if time == 100 && !is_clear:
        MusicManager.changeMusic("timeup")
    if time <= 0:
        if !is_clear:
            get_node("../Player").death()
        timer.stop()

# 通关结算
# 加速流逝，配合计时器进行通关时间结算
func clear():
    timer.wait_time = 0.01
    is_clear = true
