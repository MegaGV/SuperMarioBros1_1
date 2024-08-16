extends Block

class_name QuestionBox

@onready var animated_sprite_2d = $AnimatedSprite2D

enum BonusType{
	COIN,
	LEVELUP,
	ONEUP,
	STAR
}

enum BonusStatus{
	NORMAL,
	BRICK,
	INVISIBLE,
	EMPTY
}

@export var bonus_array = [BonusType.COIN]
@export var bonus_status = BonusStatus.NORMAL

func _ready():
	if bonus_status == BonusStatus.INVISIBLE:
		animated_sprite_2d.visible = false
	elif bonus_status == BonusStatus.BRICK:
		animated_sprite_2d.play("brick")

func bump(player_mode: Player.PlayerMode):
	if bonus_array.is_empty():
		return
	bump_up()
	bonusOut(player_mode)
	empty_box_check()

func bonusOut(player_mode: Player.PlayerMode):
	match bonus_array.pop_back():
		BonusType.COIN:
			print("coin")
			SpawnUtils.spawn_coin(position)
		BonusType.LEVELUP:
			print("levelup")
			SpawnUtils.spawn_level_up(position, player_mode)
		BonusType.ONEUP:
			print("oneup")
			SpawnUtils.spawn_one_up(position, player_mode)
		BonusType.STAR:
			print("star")

func empty_box_check():
	if (bonus_array.is_empty()):
		animated_sprite_2d.play("empty")
		# make invisible box visible
		if bonus_status == BonusStatus.INVISIBLE:
			animated_sprite_2d.visible = true
