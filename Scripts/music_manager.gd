extends Node

const BGM_UNDERGROUND = preload("res://Assets/sound/UNDERGROUND.mp3")
const BGM_GROUND = preload("res://Assets/sound/GROUND.mp3")
const BGM_CASTLE = preload("res://Assets/sound/Castle.mp3")
const BGM_DEATH = preload("res://Assets/sound/DEATH.mp3")
const BGM_INVINCIBLE = preload("res://Assets/sound/INVINCIBLE.mp3")
const BGM_FLAGPOLE = preload("res://Assets/sound/smb_flagpole.mp3")

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(music_player)

func changeMusic(stage: String, time = -1):
	music_player.stop()
	match (stage):
		"main":
			music_player.stream = BGM_GROUND
			if time < 100:
				music_player.play(189.3)
			else:
				music_player.play()
		"Underground":
			music_player.stream = BGM_UNDERGROUND
			if time < 100:
				music_player.play(39.5)
			else:
				music_player.play()
		"castle":
			music_player.stream = BGM_CASTLE
			music_player.play()
			await get_tree().create_timer(6).timeout
			music_player.stop()
		"death":
			music_player.stream = BGM_DEATH
			music_player.play()
		"invincible":
			music_player.stream = BGM_INVINCIBLE
			music_player.play()
		"timeup":
			music_player.stream = BGM_GROUND
			music_player.play(186.0)
		"flagpole":
			music_player.stream = BGM_FLAGPOLE
			music_player.play()
