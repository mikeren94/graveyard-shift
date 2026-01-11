extends CharacterBody3D

@export var speed := 2.0
@export var health := 30
@export var gravity := 30.0
@export var attack_range := 1.5
@export var attack_damage := 10
@export var attack_cooldown := 1.0

var attack_timer := 0.0
var player:CharacterBody3D = null
var agent: NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("Player")
	agent = $NavigationAgent3D

func _physics_process(delta):
	attack_timer -= delta
	if not player:
		return

	# Check distance to player
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	
	if dist <= attack_range:
		try_attack()
		return # Don't move while attacking
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Navigation movement (horizontal only)
	agent.target_position = player.global_transform.origin
	var next_point = agent.get_next_path_position()

	var direction = (next_point - global_transform.origin)
	direction.y = 0  # <-- CRITICAL: remove vertical movement
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
	
func hit(damage):
	health -= damage
	print ("Zombie hit! Health:", health)
	
	if health <= 0:
		die()
		
func die():
	queue_free()
	
func try_attack():
	if attack_timer > 0:
		return

	attack_timer = attack_cooldown
	player.take_damage(attack_damage, global_transform.origin)
