extends Area2D

class_name TransportArea

enum ENTER_DIRECTION {
	DOWN,
	RIGHT,
	UP,
	LEFT,
	NONE
}

@export var valiable = true
@export var exitPos = Vector2.ZERO
@export var enterDirection = ENTER_DIRECTION.DOWN
@export var exitScenePath: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func transportCheck(pos: Vector2):
	match enterDirection:
		ENTER_DIRECTION.DOWN:
			return pos.y <= global_position.y
		ENTER_DIRECTION.RIGHT:
			return pos.x <= global_position.x
		ENTER_DIRECTION.UP:
			return pos.y >= global_position.y
		ENTER_DIRECTION.LEFT:
			return pos.x >= global_position.x
