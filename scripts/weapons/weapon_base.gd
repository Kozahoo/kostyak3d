# weapons/base_weapon.gd
class_name BaseWeapon
extends Node3D

# Exported properties for weapon tuning
@export var weapon_name := "Weapon"
@export var damage := 10
@export var fire_rate := 0.2 # seconds between shots
@export var bullet_speed := 50.0
@export var bullet_spread_x := 0.05
@export var bullet_spread_y := 0.05
@export var bullet_count := 1
@export var max_ammo := 30
@export var reload_time := 1.5
@export var automatic := false # hold to fire or click per shot

@export var bullet_scene: PackedScene
@export var muzzle_flash: GPUParticles3D
@export var muzzle_smoke_delay := .15
@onready var muzzle_smoke_delay_timer := Timer.new()
@export var muzzle_light: Light3D
@export var muzzle_smoke: PackedScene
@export var muzzle_light_duration := 0.05 # How long light stays visible

# Sound arrays
@export var equip_sounds: Array[AudioStream]
@export var fire_sounds: Array[AudioStream]
@export var reload_start_sounds: Array[AudioStream]
@export var reload_finish_sounds: Array[AudioStream]
@export var empty_sounds: Array[AudioStream]

@onready var fx_audio_player: AudioStreamPlayer3D = $FXAudioPlayer
@onready var fire_audio_player: AudioStreamPlayer3D = $FireAudioPlayer

@export var muzzle: Node3D

signal equiped()
signal fired()
signal ammo_updated(current, max)
signal reload_started(reload_time)
signal reload_finished()

var current_ammo: int
var is_reloading := false
var reload_timer: Timer
var fire_cooldown_timer: Timer
var muzzle_light_timer: Timer
var can_shoot := true

func _ready():
	current_ammo = max_ammo
	setup_reload_timer()
	setup_fire_cooldown_timer()
	setup_muzzle_light_timer()
	
	# Hide muzzle light initially
	if muzzle_light:
		muzzle_light.visible = false
	
	muzzle_smoke_delay_timer.wait_time = muzzle_smoke_delay
	muzzle_smoke_delay_timer.one_shot = true
	muzzle_smoke_delay_timer.timeout.connect(_on_muzzle_smoke_delay_timeout)
	add_child(muzzle_smoke_delay_timer)

func setup_reload_timer():
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	add_child(reload_timer)

func setup_fire_cooldown_timer():
	fire_cooldown_timer = Timer.new()
	fire_cooldown_timer.one_shot = true
	fire_cooldown_timer.timeout.connect(_on_fire_cooldown_timeout)
	add_child(fire_cooldown_timer)

func setup_muzzle_light_timer():
	muzzle_light_timer = Timer.new()
	muzzle_light_timer.one_shot = true
	muzzle_light_timer.timeout.connect(_on_muzzle_light_timeout)
	add_child(muzzle_light_timer)

func equip():
	play_sound(equip_sounds.pick_random())
	equiped.emit()

func can_fire() -> bool:
	return current_ammo > 0 and not is_reloading and can_shoot

func set_ammo(new_value: int):
	current_ammo = clamp(new_value, 0, max_ammo)
	ammo_updated.emit(current_ammo, max_ammo)

func add_ammo(number: int):
	set_ammo(current_ammo + number)

func fire(ignore_cooldown: bool = false):
	if can_shoot and not is_reloading and current_ammo <= 0:
		play_sound(empty_sounds.pick_random())
		can_shoot = false
		fire_cooldown_timer.start(fire_rate)
	if not can_fire():
		return
	
	if not ignore_cooldown and not can_shoot:
		return
	
	add_ammo(-1)
	can_shoot = false
	fire_cooldown_timer.start(fire_rate)
	
	# Play effects
	play_muzzle_effects()
	play_sound(fire_sounds.pick_random(), fire_audio_player)

	# Create bullets
	for i in bullet_count:
		var bullet = bullet_scene.instantiate()
		# Set bullet position/rotation
		bullet.global_transform = muzzle.global_transform
		get_tree().root.add_child(bullet)
		
		# Apply spread
		var spread_x = randf_range(-bullet_spread_x, bullet_spread_x)
		var spread_y = randf_range(-bullet_spread_y, bullet_spread_y)
		bullet.rotate_x(spread_x)
		bullet.rotate_y(spread_y)
		
		# Set bullet velocity
		if bullet.has_method("initialize"):
			bullet.initialize(bullet_speed, damage)
	
	fired.emit()

func play_muzzle_effects():
	# Particles
	if muzzle_flash:
		muzzle_flash.restart()
	
	# Light flash
	if muzzle_light:
		muzzle_light.visible = true
		muzzle_light_timer.start(muzzle_light_duration)
	
	muzzle_smoke_delay_timer.start(muzzle_smoke_delay)

func _on_muzzle_smoke_delay_timeout():
	if muzzle_smoke:
		var smoke_instance = muzzle_smoke.instantiate()
		get_tree().root.add_child(smoke_instance)

		# Position smoke at muzzle
		smoke_instance.global_transform = muzzle.global_transform

		# Configure smoke to auto-remove after playing
		smoke_instance.finished.connect(smoke_instance.queue_free)
		smoke_instance.emitting = true

func _on_muzzle_light_timeout():
	if muzzle_light:
		muzzle_light.visible = false

func _on_fire_cooldown_timeout():
	can_shoot = true

func reload():
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	reload_started.emit(reload_time)
	
	play_sound(reload_start_sounds.pick_random())
	
	# Start the reload timer
	reload_timer.start(reload_time)

func reload_interrupt():
	reload_timer.stop()
	is_reloading = false
	play_sound(equip_sounds.pick_random())

func _on_reload_timer_timeout():
	set_ammo(max_ammo)
	is_reloading = false
	reload_finished.emit()
	if reload_finish_sounds.size() > 0:
		play_sound(reload_finish_sounds.pick_random())
	else:
		play_sound(equip_sounds.pick_random())

func play_sound(sound: AudioStream, player: AudioStreamPlayer3D = fx_audio_player):
	if not player: return
	if not sound: return
	player.stream = sound
	player.play()
