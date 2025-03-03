extends Area2D

class_name TransportArea

# 传送区域
# 放在管道口的判定区域

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

# 根据玩家位置，返回进入管道时的方向，再根据这个方向播放动画
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
