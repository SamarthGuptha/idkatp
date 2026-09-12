extends Node2D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 50
@export var spawn_interval: float = 3.0

@onready var timer = $Timer
@onready var spawn_points = $SpawnPoints.get_children()

var current_enemy_count: int = 0

func _ready():
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()
	
func _on_spawn_timer_timeout():
	if current_enemy_count < max_enemies and spawn_points.size() > 0: spawn_enemy()
	
func spawn_enemy():
	var random_marker: Marker2D = spawn_points.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = random_marker.global_position
	
	enemy.tree_exited.connect(_on_enemy_removed)
	
	get_tree().current_scene.add_child(enemy)
	current_enemy_count +=1

func _on_enemy_removed():
	current_enemy_count = max(0, current_enemy_count -1)
	
