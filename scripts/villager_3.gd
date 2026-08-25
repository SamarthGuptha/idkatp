extends Area2D

@export_multiline var dialog: Array[String] = [
	"Hello!! I see you wanna cross the bridge eh?",
	"sing us a song you're the piano man",
	"sing us a song tonight",
]

@onready var dialog_box = $CanvasLayer/TextureRect
