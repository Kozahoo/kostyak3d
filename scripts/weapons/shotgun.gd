extends BaseWeapon

func _ready():
	weapon_name = "Pistol"
	damage = 15
	fire_rate = 0.1
	bullet_speed = 45.0
	bullet_spread_x = .1
	bullet_spread_y = .1
	bullet_count = 8
	max_ammo = 32
	reload_time = 1.2
	automatic = true
	
	super._ready()
