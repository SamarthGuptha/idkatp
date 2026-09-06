extends Area2D
@onready var prompt= $Label
@export_multiline var dialog: Array[String] = [
	"Hello there, traveler!",
	"I heard there are 4 magical gems scattered around 3 worlds",
	"You need 70 coins to go to travel to the second world!",
	"which you can make by hunting the slimes and skeletons!",
	"Be careful, if you die you loose 3 coins!",
	"Good Luck!"
]

@onready var dialog_box = $CanvasLayer/TextureRect
@onready var dialog_text = $CanvasLayer/TextureRect/RichTextLabel

var player_in_range: bool = false
var is_chatting: bool = false
var is_typing: bool = false
var current_line:int =0
var tween: Tween

func _ready():
	dialog_box.visible = false
	prompt.visible = false



func _on_body_entered(body: Node2D) -> void:
	if body.name =="Player": 
		player_in_range = true
		prompt.visible = true
	


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range=false
		end_dialog()
		prompt.visible = false

func _input(event):
	if player_in_range and event.is_action_pressed("pickup"):
		prompt.visible=false
		if not is_chatting: start_dialog()
		elif is_typing:
			tween.kill()
			dialog_text.visible_ratio = 1.0
			is_typing=false
		else: next_line()


func start_dialog():
	is_chatting=true
	dialog_box.visible = true
	current_line=0
	type_out_text()

func next_line():
	current_line+=1
	if current_line < dialog.size(): type_out_text()
	else: end_dialog()

func end_dialog():
	is_chatting = false
	dialog_box.visible = false
	
func type_out_text():
	dialog_text.text = dialog[current_line]
	dialog_text.visible_ratio =0.0
	is_typing = true
	
	var duration: float = dialog_text.text.length()*0.05
	tween = create_tween()
	tween.tween_property(dialog_text, "visible_ratio",1.0, duration)
	tween.finished.connect(func(): is_typing = false)
	
	
	
