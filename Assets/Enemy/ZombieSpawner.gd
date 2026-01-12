extends Node3D

@export var zombie_scene: PackedScene
@export var spawn_interval := 3.0   # seconds between spawns
@export var max_zombies := 20       # optional cap
@export var spawn_radius := 20.0    # how far from the player zombies appear (used for random mode)

var timer := 0.0
var player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	timer = spawn_interval
	print("Zombie spawner running")

func _process(delta):
	if not player:
		return

	timer -= delta
	if timer <= 0:
		spawn_zombie()
		timer = spawn_interval

func spawn_zombie():
	# Optional: limit total zombies
	if get_tree().get_nodes_in_group("Zombies").size() >= max_zombies:
		return

	var zombie = zombie_scene.instantiate()

	# ---------------------------------------------------------
	# ORIGINAL RANDOM SPAWN CODE (disabled for now)
	# ---------------------------------------------------------
	# This spawns zombies in a circle around the player.
	# Keep this for later if you want to re-enable random spawns.
	#
	# var angle = randf() * TAU
	# var offset = Vector3(cos(angle), 0, sin(angle)) * spawn_radius
	# zombie.global_transform.origin = player.global_transform.origin + offset
	# ---------------------------------------------------------

	# ---------------------------------------------------------
	# NEW BEHAVIOUR: Spawn at the spawner's position
	# ---------------------------------------------------------
	zombie.global_transform.origin = global_transform.origin

	# Add to the scene
	get_tree().current_scene.add_child(zombie)
