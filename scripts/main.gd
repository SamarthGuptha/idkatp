extends Node2D
var levelNum: int = 1
var currentLevelRoot: Node = null

func _ready() -> void:
	currentLevelRoot = get_node("levelRoot")
	
	var exit = currentLevelRoot.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)

func _loadLevel(levelNum: int) -> void:
	pass
		
	


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		levelNum+=1
