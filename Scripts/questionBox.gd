@tool
extends Block

class_name QuestionBox

# 问号盒子

@onready var animated_sprite_2d = $AnimatedSprite2D

enum BonusType{
    COIN,
    LEVELUP,
    ONEUP,
    STAR # 没做,没错,藤蔓,没有
}

# 普通、越共、恋恋、空空
enum BonusStatus{
    NORMAL,
    BRICK,
    INVISIBLE,
    EMPTY
}

# 因为可能有复数道具，所以需要用数组
@export var bonus_array = [BonusType.COIN]
@export var bonus_status = BonusStatus.NORMAL

func _ready():
    bonus_array = bonus_array.duplicate()  # Make bug happy https://github.com/godotengine/godot/issues/96181
    # 默认是问号盒子动画，如果是其他类型在生成时动态调整
    if bonus_status == BonusStatus.INVISIBLE:
        animated_sprite_2d.visible = false
    elif bonus_status == BonusStatus.BRICK:
        animated_sprite_2d.play("brick")

func bump(player_mode: Player.PlayerMode):
    if bonus_array.is_empty():
        return
    bump_up() # 砖块通用的顶起逻辑
    bonusOut(player_mode) # 道具生成
    empty_box_check() # 还有莫得

# 根据内藏的奖励生成对应道具
func bonusOut(player_mode: Player.PlayerMode):
    match bonus_array.pop_back():
        BonusType.COIN:
            SpawnUtils.spawn_coin(position)
        BonusType.LEVELUP:
            SpawnUtils.spawn_level_up(position, player_mode)
            SoundManager.bonus_appear.play()
        BonusType.ONEUP:
            SpawnUtils.spawn_one_up(position)
            SoundManager.bonus_appear.play()
        BonusType.STAR:
            print("star")
            SoundManager.bonus_appear.play()

# 当没有道具剩余后变成空盒子
func empty_box_check():
    if (bonus_array.is_empty()):
        animated_sprite_2d.play("empty")
        # make invisible box visible
        if bonus_status == BonusStatus.INVISIBLE:
            animated_sprite_2d.visible = true
