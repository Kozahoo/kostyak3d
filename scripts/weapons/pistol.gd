# weapons/pistol/pistol.gd
extends BaseWeapon

func _ready():
	weapon_name = "Pistol"
	damage = 15
	fire_rate = 0.5
	bullet_speed = 60.0
	bullet_spread = 0.02
	bullet_count = 1
	max_ammo = 32
	reload_time = 1.2
	automatic = false
	
	super._ready()
