extends BaseWeapon

func _ready():
	weapon_name = "Shotgun"
	damage = 6
	fire_rate = 0.75
	bullet_speed = 150.0
	bullet_spread_x = .1
	bullet_spread_y = .05
	bullet_count = 16
	max_ammo = 8
	reload_time = 1.5
	automatic = true
	
	super._ready()
