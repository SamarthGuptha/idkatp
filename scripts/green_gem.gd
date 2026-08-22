extends Area2D
@export var gem_name: String = "GreenGem"
@onready var prompt = $Label
var can_collect: bool = false
@onready var pickupsound: AudioStreamPlayer2D= $AudioStreamPlayer2D
func _ready():
	prompt.visible=false



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_collect = true
		prompt.visible=true




func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		can_collect = false
		prompt.visible = false
func _input(event):
	if can_collect and event.is_action_pressed("pickup"):
		if PlayerStats.add_item(gem_name):
			pickupsound.play()
			$Sprite2D.visible = false
			await pickupsound.finished
			queue_free()
