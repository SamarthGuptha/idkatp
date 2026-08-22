extends VBoxContainer


func _process(_delta):
	for i in range(get_child_count()):
		var slot = get_child(i)
		var item= PlayerStats.inventory[i]
		var textureRect = slot.get_node("TextureRect")
		
		if item !=null:
			textureRect.texture = PlayerStats.item_textures[item]
		else:
			textureRect.texture=null
		
		
