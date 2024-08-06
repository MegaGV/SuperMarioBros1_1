extends Node

# 已设置自动加载，可全局直接调用
# class_name ScoreUtil

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")

func spawn_points_label(area: Area2D, score: int):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.text = str(score)
	points_label.position = area.global_position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	#emit_signal("points_scored", score)
