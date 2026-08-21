extends Label

func _process(_delta):
	text = "Coins: "+str(PlayerStats.coins)
