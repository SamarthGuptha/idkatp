extends Node2D
var levelNum: int = 1
var currentLevelRoot: Node = null
@onready var hud: CanvasLayer = $HUD
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
	var player = levelRoot.get_node("Player")
	$HUD.set_player(player)
	player.died.connect(_on_player_died)
	
	
	var exit = levelRoot.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		levelNum+=1
		call_deferred("_load_level", levelNum)
		
func _on_player_died() -> void:
	get_tree().create_timer(1.5).timeout
	await hud.fade(1.0)
	levelNum = 1
	PlayerStats.reset()
	_load_level(levelNum)
	await hud.fade(0.0)
