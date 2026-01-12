extends CharacterBody3D

@export var mouse_sensitivity: float = 0.1
@export var controller_sensitivity: float = 3.0
@export var move_speed: float = 10.0
@export var look_limit: float = 80.0
@export var recoil_strength: float = 5.0
@export var recoil_recovery_speed: float = 10.0
@export var max_health := 100
@export var gravity := 30.0
@export var knockback_strength := 20
@export var hitmarker_duration := 0.15

var health = max_health
var camera
var pitch = 0.0
var recoil_current: float = 0.0
var health_bar: ProgressBar
var hitmarker: Label
var hitmarker_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = $GameCamera
	health_bar = get_tree().root.get_node("Main/PlayerUI/HealthBar")
	hitmarker = get_tree().root.get_node("Main/PlayerUI/Hitmarker")
	health_bar.value = max_health
	hitmarker.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_handle_mouse_look(event)

func _input(event):
	if event.is_action_pressed("shoot"):
		$GameCamera/Gun.shoot()
		
func add_recoil():
	recoil_current += recoil_strength

func _physics_process(delta: float):
	_handle_movement(delta)
	#_handle_controller_look(delta)
	# Recoil recovers towards zero
	recoil_current = lerp(recoil_current, 0.0, recoil_recovery_speed * delta)
	camera.rotation_degrees.x = pitch + recoil_current
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		
	if hitmarker_timer > 0:
		hitmarker_timer -= delta
		if hitmarker_timer <= 0:
			hitmarker.visible = false

func _handle_mouse_look(event):
	var yaw = -event.relative.x * mouse_sensitivity
	var pitch_delta = -event.relative.y * mouse_sensitivity

	rotate_y(deg_to_rad(yaw))
	pitch = clamp(pitch + pitch_delta, -look_limit, look_limit)

# func _handle_controller_look(delta):
# 	var lx = Input.get_action_strength("look_x")
# 	var ly = Input.get_action_strength("look_y")

# 	if (abs(lx) > 0.1 or abs(ly) > 0.1):
# 		rotate_y(-lx * controller_sensitivity * delta)
# 		pitch = clamp(pitch - ly * controller_sensitivity * delta, -look_limit, look_limit)
# 		camera.rotation_degrees.x = pitch

func _handle_movement(_delta):

	# Keybopard movement
	var forward = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var strafe = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	# # Controller movement
	# var joy_x = Input.get_action_strength("move_x")
	# var joy_y = Input.get_action_strength("move_y")

	# # Combine both (controller overides if active)
	# if abs(joy_x) > 0.1 or abs(joy_y) > 0.1:
	# 	strafe = joy_x
	# 	forward = joy_y * -1.0

	var direction = (transform.basis * Vector3(strafe, 0, -forward)).normalized()
	velocity.x = lerp(velocity.x, direction.x * move_speed, 0.2)
	velocity.z = lerp(velocity.z, direction.z * move_speed, 0.2)

	move_and_slide()

func take_damage(amount: int, attacker_position: Vector3) -> void:
	# Play sound
	if $PlayerHit:
		$PlayerHit.play()
	health -= amount
	health_bar.value = health
	
	# Knockback direction (from attacker → player)
	var knock_dir = (global_transform.origin - attacker_position).normalized()
	knock_dir.y = 0  # keep knockback horizontal

	# Apply knockback impulse
	velocity += knock_dir * knockback_strength

	if health <= 0:
		die()

func die() -> void:
	print("player died")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
	
func show_hitmarker():
	hitmarker.visible = true
	hitmarker.modulate.a = 1.0
	hitmarker_timer = hitmarker_duration
