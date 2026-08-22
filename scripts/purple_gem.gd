extends Area2D
var can_collect: bool = false
@export var gem_name: String = "PurpleGem"
@onready var prompt = $Label
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
func _ready():
	prompt.visible=false 


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_collect = true
		prompt.visible= true
		



func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		can_collect=false
		prompt.visible = false

func _input(event):
	if can_collect and event.is_action_pressed("pickup"):
		if PlayerStats.add_item(gem_name): 
			sound.play()
			$Sprite2D.visible = false
			await sound.finished
			queue_free()
