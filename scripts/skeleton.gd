extends CharacterBody2D

enum State {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
	STAGGER,
	DEAD
}

var current_state = State.IDLE
var state_time: float = 0.0
@export var move_speed = 80.0
var startPos:Vector2
var wanderTarget: Vector2
var TargetPlayer: CharacterBody2D = null
@onready var sightArea = $Sight
@export var attack_damage:int = 10
@export var attack_range: float = 40.0
@export var lunge_speed: float = 250.0
@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var attack_timer = $AttackTimer
func _ready():
	startPos = global_position
	state_time = randf_range(1.0, 3.0)
	sightArea.body_entered.connect(_on_sight_body_entered)
	sightArea.body_exited.connect(_on_sight_body_exited)
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.monitoring = false

func _physics_process(delta):
	match current_state:
		State.IDLE: state_idle(delta)
		State.WANDER: state_wander(delta)
		State.CHASE: state_chase(delta)
		State.ATTACK: pass
		State.DEAD: pass
		State.STAGGER: pass
	
	move_and_slide()
	
func state_wander(delta):
	
	if has_line_of_sight():
		current_state = State.CHASE
		return
		
	var direction = global_position.direction_to(wanderTarget)
	velocity = direction * (move_speed * 0.5)
	anim.play("run_front")
	
	state_time -= delta
	if global_position.distance_to(wanderTarget)<5.0 or state_time<=0:
		current_state = State.IDLE
		state_time = randf_range(1.0, 3.0)

func state_idle(delta):
	if has_line_of_sight():
		current_state = State.CHASE
		return
	
	velocity = Vector2.ZERO
	anim.play("idle")
	state_time -=delta
	if state_time <=0:
		current_state = State.WANDER
		pick_new_wander_target()
		

func state_chase(delta):
	if not has_line_of_sight():
		current_state = State.WANDER
		pick_new_wander_target()
		return
	
	var distance_to_player = global_position.distance_to(TargetPlayer.global_position)
	
	if distance_to_player <= attack_range and attack_timer.is_stopped():
		current_state = State.ATTACK
		perform_attack()
		return
	
	var direction = global_position.direction_to(TargetPlayer.global_position)
	velocity = direction*move_speed
	anim.play("run_front")



func pick_new_wander_target():
	var randomDir = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	var randomDist = randf_range(20.0,60.0)
	
	wanderTarget = startPos+(randomDir*randomDist)
	state_time = randf_range(2.0, 4.0)
	


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		TargetPlayer = body
		


func _on_sight_body_exited(body: Node2D) -> void:
	if body == TargetPlayer: TargetPlayer = null

func has_line_of_sight() -> bool:
	if TargetPlayer == null: return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, TargetPlayer.global_position)
	query.exclude=[self]
	var result = space_state.intersect_ray(query)
	if result and result.collider == TargetPlayer: return true
	
	return false

func state_attack(delta): pass

func perform_attack():
	velocity = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color(1, 0, 0, 1), 0.3)
	await tween.finished
	
	if current_state != State.ATTACK:
		anim.modulate = Color.WHITE
		return
	
	if TargetPlayer:
		var lunge_dir = global_position.direction_to(TargetPlayer.global_position)
		velocity = lunge_dir*lunge_speed
		
	hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	
	velocity = Vector2.ZERO
	hitbox.monitoring = false
	anim.modulate = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	if current_state == State.ATTACK:
		current_state = State.IDLE
		attack_timer.start(1.5)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(attack_damage)
		
		

	
