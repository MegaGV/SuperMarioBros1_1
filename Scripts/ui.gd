extends CanvasLayer

class_name MarioUI

@onready var hud : TileMapLayer = $hud

const scorePos = 6
const socreSize = 4 # 000000
const coinPos = 14
const coinSize = 2 # 00
const timePos = 28
const timeSize = 3 # 400

func update_score(score: int):
    update_hud_tile(transfer_number(score / 100, socreSize), scorePos)

func update_coin(coin: int):
    update_hud_tile(transfer_number(coin, coinSize), coinPos)

func update_time(time: int):
    update_hud_tile(transfer_number(time, timeSize), timePos)

func transfer_number(number: int, limitSize: int) -> Array:
    var digits = []
    var number_as_string = str(number)
    for numberChar in number_as_string:
        digits.append(int(numberChar))
    digits.reverse()
    while digits.size() < limitSize:
        digits.append(0)
    return digits

func get_tile_digit(digit: int) -> Vector2:
    return Vector2(digit, 0)

func update_hud_tile(digits: Array, hudPos: int):
    for digit in digits:
        var tilePos = get_tile_digit(digit)
        hud.set_cell(Vector2(hudPos, 3), 0, tilePos)
        hudPos -= 1
