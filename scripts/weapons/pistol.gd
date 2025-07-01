# weapons/pistol/pistol.gd
extends BaseWeapon

func _ready():
	weapon_name = "Pistol"
	damage = 15
	fire_rate = 0.5
	bullet_speed = 85.0
	bullet_spread_x = 0.0001
	bullet_spread_y = 0.0001
	bullet_count = 1
	max_ammo = 32
	reload_time = 1.2
	automatic = false
	
	super._ready()
