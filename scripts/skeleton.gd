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
@export var move_speed = 180.0
@export var acceleration = 400.0
@export var friction = 400.0
var startPos:Vector2
var wanderTarget: Vector2
var TargetPlayer: CharacterBody2D = null
var last_facing: Vector2 = Vector2.DOWN
@onready var sightArea = $Sight
@export var attack_damage:int = 10
@export var attack_range: float = 40.0
@export var lunge_speed: float = 250.0
@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var attack_timer = $AttackTimer
var attack_phase: int = 0
var attack_internal_timer: float = 0.0
var hitbox_default_x: float =0.0
@export var max_health: int = 30
var health: int = max_health

func _ready():
	health = max_health
	hitbox_default_x = hitbox.position.x
	attack_timer.one_shot = true
	startPos = global_position
	state_time = randf_range(1.0, 3.0)
	sightArea.body_entered.connect(_on_sight_body_entered)
	sightArea.body_exited.connect(_on_sight_body_exited)
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.monitoring = false
	change_state(State.IDLE)
func _physics_process(delta):
	match current_state:
		State.IDLE: state_idle(delta)
		State.WANDER: state_wander(delta)
		State.CHASE: state_chase(delta)
		State.ATTACK: state_attack(delta)
		State.DEAD: state_dead(delta)
		State.STAGGER: state_stagger(delta)
	
	move_and_slide()
	update_animation()
	
func change_state(new_state: int):
	if current_state == State.DEAD: return
	
	current_state = new_state
	match current_state:
		State.IDLE: state_time = randf_range(1.0, 3.0)
		State.WANDER: state_time=randf_range(20, 4.0)
		State.ATTACK:
			attack_phase = 0
			attack_internal_timer = 0.3
			anim.modulate = Color(1,0,0, 1)
		State.STAGGER:
			state_time = 0.4
			hitbox.monitoring = false
			anim.modulate = Color(2,0.5, 0.5, 1)
		State.DEAD:
			hitbox.monitoring = false
			sightArea.monitoring = false
			anim.modulate = Color.WHITE 

func state_wander(delta):
	
	if has_line_of_sight():
		change_state(State.WANDER)
		return
		
	var direction = global_position.direction_to(wanderTarget)
	if direction != Vector2.ZERO: last_facing = direction
	velocity = velocity.move_toward(direction*(move_speed * 0.5), acceleration * delta)
	state_time -= delta
	if global_position.distance_to(wanderTarget)<5.0 or state_time<=0:
		change_state(State.IDLE)

func state_idle(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction*delta)
	if has_line_of_sight():
		change_state(State.CHASE)
		return
	state_time -=delta
	if state_time <=0:
		change_state(State.WANDER)
		

func state_chase(delta):
	if not has_line_of_sight():
		change_state(State.CHASE)
		return
		
	
	var distance_to_player = global_position.distance_to(TargetPlayer.global_position)
	
	if distance_to_player <= attack_range and attack_timer.is_stopped():
		change_state(State.ATTACK)
		return
	
	var direction = global_position.direction_to(TargetPlayer.global_position)
	if direction != Vector2.ZERO: last_facing = direction
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)

func state_attack(delta): 
	attack_internal_timer -= delta
	match attack_phase:
		0:
			velocity = velocity.move_toward(Vector2.ZERO, friction*delta)
			if attack_internal_timer <=0:
				attack_phase = 1
				attack_internal_timer = 0.2
				hitbox.monitoring = true
				anim.modulate = Color.WHITE 
				if TargetPlayer:
					var lunge_dir = global_position.direction_to(TargetPlayer.global_position)
					last_facing = lunge_dir
					velocity = lunge_dir * lunge_speed
		1:
			if attack_internal_timer <=0:
				attack_phase = 2
				attack_internal_timer = 0.5
				hitbox.monitoring = false
				velocity = Vector2.ZERO
		2:
			velocity = velocity.move_toward(Vector2.ZERO, friction* delta)
			if attack_internal_timer <= 0:
				attack_timer.start(1.5)
				change_state(State.IDLE)

func state_dead(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction*delta)

func state_stagger(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	state_time -= delta
	if state_time <=0:
		anim.modulate = Color.WHITE
		change_state(State.IDLE)

func pick_new_wander_target():
	var randomDir = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	var randomDist = randf_range(20.0,60.0)
	
	wanderTarget = global_position + (randomDir * randomDist)
	


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		TargetPlayer = body
		


func _on_sight_body_exited(body: Node2D) -> void:
	pass

func has_line_of_sight() -> bool:
	if TargetPlayer == null: 
		return false
		
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, TargetPlayer.global_position)
	query.exclude = [get_rid()] 
	
	var result = space_state.intersect_ray(query)
	if result and result.collider == TargetPlayer: 
		return true
		
	return false


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
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(attack_damage)
		

func take_damage(amount: int):
	if current_state == State.DEAD: return
	health -= amount
	if health <= 0:
		change_state(State.DEAD)
	else: change_state(State.STAGGER)


func update_animation():
	if current_state == State.DEAD:
		anim.play("die")
		return
	var is_moving = velocity.length()>5.0
	if abs(last_facing.x) > abs(last_facing.y):
		if is_moving:
			anim.play("run_right")
		else: anim.play("idle_right")
		
		anim.flip_h = last_facing.x<0
		hitbox.position.x = abs(hitbox_default_x) * sign(last_facing.x) if hitbox_default_x != 0 else hitbox.position.x
		
	else:
		anim.flip_h = false
		if last_facing.y < 0:
			if is_moving:
				anim.play("run_back")
			else:
				anim.play("idle_back")
		else:
			if is_moving: anim.play("run_front")
			else: anim.play("idle")
