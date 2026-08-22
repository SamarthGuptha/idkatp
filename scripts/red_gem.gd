extends Area2D
var can_collect: bool=false

@export var gem_name: String = "RedGem"
@onready var prompt = $Label
@onready var pickupsound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	prompt.visible = false
	if gem_name in PlayerStats.inventory: queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		prompt.visible = true
		can_collect = true




func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		prompt.visible = false
		can_collect = false

func _input(event):
	if can_collect and event.is_action_pressed("pickup"):
		if PlayerStats.add_item(gem_name):
			prompt.visible = false
			pickupsound.play()
			$Sprite2D.visible = false
			await pickupsound.finished
			queue_free()
