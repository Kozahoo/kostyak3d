# weapons/pistol/pistol.gd
extends BaseWeapon

func _ready():
	weapon_name = "Pistol"
	damage = 12
	fire_rate = 0.25
	bullet_speed = 100.0
	bullet_spread_x = 0
	bullet_spread_y = 0
	bullet_count = 1
	max_ammo = 12
	reload_time = 1.2
	automatic = false
	
	super._ready()
