extends Node


var jump: AudioStreamPlayer
var oneup: AudioStreamPlayer
var levelup: AudioStreamPlayer
var coin: AudioStreamPlayer
var effect: AudioStreamPlayer
var breakblock: AudioStreamPlayer
var bump: AudioStreamPlayer
var fireball: AudioStreamPlayer
var firework: AudioStreamPlayer
var kick: AudioStreamPlayer
var bonus_appear: AudioStreamPlayer
var stomp: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jump = audioInit(preload("res://Assets/sound/sfx/JUMP.mp3"))
	oneup = audioInit(preload("res://Assets/sound/sfx/1UP.mp3"))
	levelup = audioInit(preload("res://Assets/sound/sfx/LEVEL UP.mp3"))
	coin = audioInit(preload("res://Assets/sound/sfx/COIN.mp3"))
	effect = audioInit(preload("res://Assets/sound/sfx/EFFECT.mp3"))
	
	breakblock = audioInit(preload("res://Assets/sound/sfx/smb_breakblock.mp3"))
	bump = audioInit(preload("res://Assets/sound/sfx/smb_bump.mp3"))
	fireball = audioInit(preload("res://Assets/sound/sfx/smb_fireball.mp3"))
	#firework = audioInit(preload("res://Assets/sound/sfx/smb_fireworks.mp3"))
	kick = audioInit(preload("res://Assets/sound/sfx/smb_kick.mp3"))
	bonus_appear = audioInit(preload("res://Assets/sound/sfx/smb_powerup_appears.mp3"))
	stomp = audioInit(preload("res://Assets/sound/sfx/smb_stomp.mp3"))

func audioInit(stream: AudioStream) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	return player

func coinRepeat():
	var coinR = audioInit(preload("res://Assets/sound/sfx/COIN.mp3"))
	coinR.play(0.5)
