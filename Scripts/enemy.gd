extends CharacterBody2D

class_name Enemy

@export var speed_x = 20
@export var speed_y = 100
@export var direction = -1

func _process(delta):
	pass

func walk(delta):
	position.x += direction * delta * speed_x
