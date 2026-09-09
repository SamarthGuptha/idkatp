extends Area2D

@onready var prompt = $Label
@export var coins_required: int = 120
@export_multiline var dialog_denied: Array[String] = [
	"Halt! This bridge is guarded.",
	"You'll need 120 coins before I let you cross",
	"Come back when you've got the coin, traveller"
]
@export_multiline var dialog_allowed: Array[String] = [
	"Ah, you've got the coins. Go on then.",
	"Safe travels!"
]
@onready var dialog_box = $CanvasLayer/TextureRect
@onready var dialog_text = $CanvasLayer/TextureRect/RichTextLabel
@onready var gate_blocker: CollisionShape2D = $StaticBody2D/CollisionShape2D

var dialog: Array[String] = []
var player_in_range: bool = false
var is_chatting: bool = false
var is_typing: bool = false
var current_line: int = 0
var tween: Tween
var has_paid: bool = false 

func _ready():
	dialog_box.visible = false
	prompt.visible = false
	update_gate()
	

func update_gate() -> void:
	has_paid = PlayerStats.coins >= coins_required
	if gate_blocker:
		gate_blocker.set_deferred("disabled", has_paid)
	PlayerStats.coins = max(0, PlayerStats.coins)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range=false
		end_dialog()
		prompt.visible = false

func _input(event):
	if player_in_range and event.is_action_pressed("pickup"):
		prompt.visible = false
		if not is_chatting: start_dialog()
		elif is_typing:
			tween.kill()
			dialog_text.visible_ratio = 1.0
			is_typing = false
		else: next_line()
	

func start_dialog():
	is_chatting=true
	dialog_box.visible = true 
	current_line=0
	update_gate()
	dialog = dialog_allowed if has_paid else dialog_denied
	type_out_text()



func end_dialog():
	is_chatting = false
	dialog_box.visible=false
	

func next_line():
	current_line+=1
	if current_line<dialog.size(): type_out_text()
	else: end_dialog()

func type_out_text():
	dialog_text.text = dialog[current_line]
	dialog_text.visible_ratio = 0.0
	is_typing = true
	var duration: float = dialog_text.text.length()*0.05
	tween = create_tween()
	tween.tween_property(dialog_text, "visible_ratio",1.0, duration)
	tween.finished.connect(func(): is_typing=false)
