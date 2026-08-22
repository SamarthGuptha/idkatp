extends Node

var coins: int = 0
var health: int = 100
var inventory: Array = [null, null,null, null]
var max_health: int=100

var item_textures: Dictionary = {
	"PurpleGem": preload("res://assets/images/gems/GemPurple.png"),
	"GreenGem": preload("res://assets/images/gems/GemGreen.png"),
	"RedGem": preload("res://assets/images/gems/GemRed.png"),
	"YellowGem": preload("res://assets/images/gems/GemYellow.png")
}


func reset() -> void:
	health = max_health

func add_item(item_name: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] ==null:
			inventory[i] = item_name
			return true
	return false
