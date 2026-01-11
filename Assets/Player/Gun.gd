extends Node3D

@export var damage := 10
@export var fire_rate := 0.2

var recoil_srength := 2.0
var recoil_recovery_speed := 10.0
var recoil_current := 0
var can_fire := true
var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
func shoot():
	if not can_fire:
		return
	
	can_fire = false
	_fire()

	# Start cooldown timer
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func _fire():
	get_tree().get_first_node_in_group("Player").add_recoil()

	# Play sound
	if $GunshotSound:
		$GunshotSound.play()

	var ray = $RayCast3D

	if ray.is_colliding():
		
		var target = ray.get_collider()

		if target.has_method("hit"):
			player.show_hitmarker()
			target.hit(damage)

		print("Hit: ", target)
	else:
		pass
		#print("Miss")
