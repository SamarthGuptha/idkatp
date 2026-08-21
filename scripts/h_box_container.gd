extends HBoxContainer
func _process(_delta):
	for i in range(get_child_count()):
		var slot = get_child(i)
		var item = PlayerStats.inventory[i]
