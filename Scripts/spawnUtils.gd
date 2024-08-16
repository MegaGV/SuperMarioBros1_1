extends Node

# 已设置自动加载，可全局直接调用
# class_name ScoreUtil

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const COIN_SCENE = preload("res://Scenes/coin.tscn")
const LEVEL_UP_SCENE = preload("res://Scenes/level_up.tscn")
const ONE_UP_SCENE = preload("res://Scenes/one_up.tscn")

func spawn_text_label(textPos: Vector2, text):
	var spawner = POINTS_LABEL_SCENE.instantiate()
	if text is int:
		spawner.text = str(text)
	else:
		spawner.text = text
	spawner.position = textPos + Vector2(-20, -20)
	get_tree().root.add_child(spawner)
	#emit_signal("points_scored", score)

func spawn_coin(spawnPosition: Vector2):
	var spawner = COIN_SCENE.instantiate()
	spawner.position = spawnPosition
	spawner.spawned = true
	get_tree().root.add_child(spawner)
	get_tree().get_first_node_in_group("level_manager").on_coin_collected()

func spawn_level_up(spawnPosition: Vector2, player_mode: Player.PlayerMode):
	var spawner = LEVEL_UP_SCENE.instantiate()
	if !player_mode == Player.PlayerMode.SMALL:
		spawner.type = LevelUp.LEVELUP_TYPE.FLOWER
	spawner.position = spawnPosition
	get_tree().root.add_child(spawner)

func spawn_one_up(spawnPosition: Vector2, player_mode: Player.PlayerMode):
	var spawner = ONE_UP_SCENE.instantiate()
	spawner.position = spawnPosition
	get_tree().root.add_child(spawner)
