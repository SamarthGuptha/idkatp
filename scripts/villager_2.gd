extends Area2D
@export_multiline var dialog: Array[String] = [
	"Hello!! I see you wanna cross the bridge eh?",
	"Well well well, that would cost you 20 coins",
]

@onready var dialog_box = $CanvasLayer/TextureRect
@onready var dialog_text = $CanvasLayer/TextureRect/RichTextLabel

var player_in_range: bool = false
var is_chatting: bool=false
var is_typing: bool = false
var current_line: int  = 0
var tween: Tween

func _ready():
	dialog_box.visible = false



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true




func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
