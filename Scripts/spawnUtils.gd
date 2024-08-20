extends Node

# 已设置自动加载，可全局直接调用
# class_name ScoreUtil

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const COIN_SCENE = preload("res://Scenes/coin.tscn")
const LEVEL_UP_SCENE = preload("res://Scenes/level_up.tscn")
const ONE_UP_SCENE = preload("res://Scenes/one_up.tscn")
const FIRE_BALL_SCENE = preload("res://Scenes/fire_ball.tscn")
const EXPLOSION_SCENE = preload("res://Scenes/explosion.tscn")

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

func spawn_coin(spawnPosition: Vector2):
	var spawner = COIN_SCENE.instantiate()
	spawner.position = spawnPosition
	spawner.spawned = true
	get_tree().root.add_child(spawner)

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

func spawn_fire_ball(spawnPosition: Vector2, direction: int):
	var fire_ball_count = get_tree().get_nodes_in_group("fireballs").size()
	if (fire_ball_count >= 3):
		return
	var spawner = FIRE_BALL_SCENE.instantiate()
	spawner.position = spawnPosition
	spawner.direction = direction
	get_tree().root.add_child(spawner)

func spawn_explosion(spawnPosition: Vector2):
	var spawner = EXPLOSION_SCENE.instantiate()
	spawner.position = spawnPosition
	get_tree().root.add_child(spawner)
