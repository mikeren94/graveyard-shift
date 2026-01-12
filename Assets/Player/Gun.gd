extends Node3D

@export var damage := 10
@export var fire_rate := 0.2
@export var ammo := 100
@export var ammo_capacity := 10.0
@export var reload_time := 2.1

var recoil_srength := 2.0
var recoil_recovery_speed := 10.0
var recoil_current := 0
var can_fire := true
var player: CharacterBody3D
var current_mag = ammo_capacity
var ammo_display: Label
var promt_reload: Label
var is_reloading = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	ammo_display = get_tree().root.get_node("Main/PlayerUI/AmmoDisplay")
	promt_reload = get_tree().root.get_node("Main/PlayerUI/PromptReload")
	var events = InputMap.action_get_events("reload")
	if events.size() > 0:
		var key_name = events[0].as_text()
		promt_reload.text = "Press " + key_name.split(" ")[0] + " to reload"
	promt_reload.visible = false
	update_gun_ui()
	
func shoot():
	if not can_fire or is_reloading:
		return
	if current_mag == 0:
		$NoAmmo.play()
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

	# Decrease ammo and mag
	ammo -= 1
	current_mag -= 1
	
	# If the ammo or current mag is 0 then the player can't fire
	if (current_mag == 0):
		promt_reload.visible = true
		can_fire = false
	# Update the ammo display as we have fired a bullet
	update_gun_ui()
	
	if ray.is_colliding():
		
		var target = ray.get_collider()

		if target.has_method("hit"):
			player.show_hitmarker()
			target.hit(damage)

		print("Hit: ", target)
	else:
		pass
		#print("Miss")

func reload():
	promt_reload.visible = false
	is_reloading = true
	$Reload.play()
	var remaining_ammo = current_mag + ammo
	# If the remaining ammo is greater than the mag capacity, then fill it to the top
	await get_tree().create_timer(reload_time).timeout

	if remaining_ammo > ammo_capacity:
		current_mag = ammo_capacity
	else:
		# Fill the gun with the remaining bullets
		current_mag = remaining_ammo
	is_reloading = false
	update_gun_ui()
		
func update_gun_ui():
	ammo_display.text = "I".repeat(current_mag)
	
