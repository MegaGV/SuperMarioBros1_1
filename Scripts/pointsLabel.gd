extends Label

class_name PointsLabel

var moveVec = Vector2(0, -10)
var duration = .4
var is_temp = true

# Called when the node enters the scene tree for the first time.
func _ready():
    var label_tween = get_tree().create_tween()
    label_tween.tween_property(self, "position", position + moveVec, duration)
    if is_temp:
        label_tween.tween_callback(queue_free)
