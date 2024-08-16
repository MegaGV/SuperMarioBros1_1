extends Node

class_name LevelManager

var score = 0
var COIN_SCORE = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_coin_collected():
	score += COIN_SCORE
	print("score: ", score)
