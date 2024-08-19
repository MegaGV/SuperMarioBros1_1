extends Node

class_name LevelManager

var score = 0
var coin = 0
var time = 400

@export var ui: MarioUI

func _ready():
	if SceneData.coin != -1:
		coin = SceneData.coin
		ui.update_coin(coin)
	if SceneData.score != -1:
		score = SceneData.score
		ui.update_score(score)
	if SceneData.time != -1:
		time = SceneData.time
		ui.update_time(time)

func on_coin_collected(pos: Vector2 = Vector2.ZERO):
	coin += 1
	if coin > 99:
		coin = 0
		on_get_extra_life()
	if pos != Vector2.ZERO:
		SpawnUtils.spawn_text_label(pos, 200)
	ui.update_coin(coin)
	on_score_get(200)

func on_score_get(scoreGet: int, pos: Vector2 = Vector2.ZERO):
	score += scoreGet
	if pos != Vector2.ZERO:
		SpawnUtils.spawn_text_label(pos, scoreGet)
	ui.update_score(score)

func on_get_extra_life():
	SpawnUtils.spawn_text_label(get_node("../Player").position, "1UP")

func switch_scene(player: Player):
	get_tree().change_scene_to_file(player.transport_path)
	SceneData.player_mode = player.player_mode
	SceneData.start_point = player.transport_to
	SceneData.coin = coin
	SceneData.score = score
	SceneData.time = time
