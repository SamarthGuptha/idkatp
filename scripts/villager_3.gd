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
@onready var gate_blocker
