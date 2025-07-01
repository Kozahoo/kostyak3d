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
@export var reload_sound: AudioStreamPlayer3D # Add this for reload sound

@export var muzzle: Node3D

var current_ammo: int
var is_reloading := false
var reload_timer: Timer

func _ready():
	current_ammo = max_ammo
	setup_reload_timer()

func setup_reload_timer():
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	add_child(reload_timer)

func can_fire() -> bool:
	return current_ammo > 0 and not is_reloading

func fire():
	if not can_fire():
		# Optionally play empty click sound here
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
			bullet.initialize(bullet_speed, damage)

func reload():
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	
	# Play reload sound if available
	if reload_sound:
		reload_sound.play()
	
	# Start the reload timer
	reload_timer.start(reload_time)

func _on_reload_timer_timeout():
	current_ammo = max_ammo
	is_reloading = false
	# You could add a reload complete sound here if needed
