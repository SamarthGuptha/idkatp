extends Area2D
@onready var drop_sound = $coin_drop
@onready var collect_sound = $coin_collect
@onready var sprite=$Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	drop_sound.play()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		PlayerStats.coins +=1
		collision.set_deferred("disabled", true)
		sprite.visible = false
		collect_sound.play()
		await collect_sound.finished
		
		queue_free()
