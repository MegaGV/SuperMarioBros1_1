extends Area2D

class_name Flag

@onready var sprite_2d = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func flag_up(pos: Vector2): # flag height 128
    var score = 100
    var height = global_position.y - pos.y
    if height > 120:
        score = 5000
    elif height > 64:
        score = 2000
    elif height > 32:
        score = 400
    
    SpawnUtils.spawn_text_label(global_position + Vector2(16,0),score, Vector2(0, -112), 1, false)
    get_tree().get_first_node_in_group("level_manager").on_score_get(score)
    
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", global_position + Vector2(0,112), 1)
