# weapons/pistol/pistol.gd
extends BaseWeapon

func _ready():
	weapon_name = "Pistol"
	damage = 12
	fire_rate = 0.2
	bullet_speed = 250.0
	bullet_spread_x = 0.01
	bullet_spread_y = 0.01
	bullet_count = 1
	max_ammo = 12
	reload_time = 0.5
	automatic = false
	
	super._ready()
