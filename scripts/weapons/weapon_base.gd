# weapons/base_weapon.gd
class_name BaseWeapon
extends Node3D

# Exported properties for weapon tuning
@export var weapon_name := "Weapon"
@export var damage := 10
@export var fire_rate := 0.2 # seconds between shots
@export var bullet_speed := 50.0
@export var bullet_spread := 0.05 # in radians
@export var bullet_count := 1
@export var max_ammo := 30
@export var reload_time := 1.5
@export var automatic := false # hold to fire or click per shot

@export var bullet_scene: PackedScene
@export var muzzle_flash: GPUParticles3D
@export var audio_player: AudioStreamPlayer3D

@export var muzzle: Node3D

var current_ammo: int

func _ready():
	current_ammo = max_ammo

func can_fire() -> bool:
	return current_ammo > 0

func fire():
	if not can_fire():
		return
	
	current_ammo -= 1
	
	# Play effects
	if muzzle_flash:
		muzzle_flash.restart()
	if audio_player:
		audio_player.play()
	
	# Create bullets
	for i in bullet_count:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		# Set bullet position/rotation
		bullet.global_transform = muzzle.global_transform
		
		# Apply spread
		var spread_x = randf_range(-bullet_spread, bullet_spread)
		var spread_y = randf_range(-bullet_spread, bullet_spread)
		bullet.rotate_x(spread_x)
		bullet.rotate_y(spread_y)
		
		# Set bullet velocity
		if bullet.has_method("initialize"):
			bullet.initialize(bullet_speed, damage, )

func reload():
	# Play reload animation/sound
	current_ammo = max_ammo
