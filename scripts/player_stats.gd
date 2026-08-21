extends Node

var coins: int = 0
var health: int = 100
var inventory: Array = [null, null,null, null, null]
var max_health: int=100

func reset() -> void:
	health = max_health

func add_item(item_name: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] ==null:
			inventory[i] = item_name
			return true
	return false
