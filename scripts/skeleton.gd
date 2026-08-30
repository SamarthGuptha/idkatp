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
@export var move_speed = 60.0
var startPos:Vector2
var wanderTarget: Vector2

@onready var anim = $AnimatedSprite2D
func _ready():
	startPos = global_position
	state_time = randf_range(1.0, 3.0)

func _physics_process(delta):
	match current_state:
		State.IDLE: state_idle(delta)
		State.WANDER: state_wander(delta)
		State.CHASE: pass
		State.ATTACK: pass
		State.DEAD: pass
		State.STAGGER: pass
	
	move_and_slide()
	
func state_wander(delta):
	var direction = global_position.direction_to(wanderTarget)
	velocity = direction * (move_speed * 0.5)
	anim.play("run_front")
	
	state_time -= delta
	if global_position.distance_to(wanderTarget)<5.0 or state_time<=0:
		current_state = State.IDLE
		state_time = randf_range(1.0, 3.0)

func state_idle(delta):
	velocity = Vector2.ZERO
	anim.play("idle")
	state_time -=delta
	if state_time <=0:
		current_state = State.WANDER
		pick_new_wander_target()
		




func pick_new_wander_target():
	var randomDir = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	var randomDist = randf_range(20.0,60.0)
	
	wanderTarget = startPos+(randomDir*randomDist)
	state_time = randf_range(2.0, 4.0)
	
