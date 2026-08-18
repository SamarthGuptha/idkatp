extends Node2D
var levelNum: int = 1
var currentLevelRoot: Node = null

func _ready() -> void:
	currentLevelRoot = get_node("levelRoot")
	_load_level(levelNum)
	
	

func _load_level(level: int) -> void:
	if currentLevelRoot:
		currentLevelRoot.queue_free()
	var levelPath = "res://scenes/levels/level_%s.tscn" % level
	currentLevelRoot = load(levelPath).instantiate()
	add_child(currentLevelRoot)
	currentLevelRoot.name = "LevelRoot"
	_setup_level(currentLevelRoot)
		
		

func _setup_level(levelRoot: Node) -> void:
	var exit = levelRoot.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		levelNum+=1
		call_deferred("_load_level", levelNum)
