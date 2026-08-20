extends CharacterBody2D
const SPEED: int = 150.0
const KNOCKBACKFORCE: int = 100
const DROP_CHANcE: float = 0.45
var health: int = 100
var target = null
var target_in_range: bool = false
var is_alive: bool = true
var strength: int = 10
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_dmg_sound: AudioStreamPlayer2D = $takeDMG
@onready var health_bar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer

var health_pickup_scene = preload("res://scenes/health_pickup.tscn")


func _physics_process(delta: float) -> void:
	if is_alive && target: _attack(delta)

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction*SPEED*delta
	animated_sprite_2d.play("attack")

func take_dmg(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	health_bar.update_health(health)
	if health <=0: _die()
	else:
		take_dmg_sound.play()
		
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction*KNOCKBACKFORCE
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "position", target_position, 0.5)
		
func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	await animated_sprite_2d.animation_finished
	if randf() <= DROP_CHANcE:
		drop_item()
	queue_free()
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null
		animated_sprite_2d.play("idle")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()


func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range=false


func drop_item():
	var drop = health_pickup_scene.instantiate()
	drop.position = position
	var level_root = get_parent().get_parent()
	var items = level_root.get_node("Items")
	items.call_deferred("add_child", drop)
	
