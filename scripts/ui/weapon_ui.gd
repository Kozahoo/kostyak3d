extends CanvasLayer

@onready var weapon_name_label: Label = $Panel/WeaponName
@onready var ammo_label: Label = $Panel/AmmoCounter
@onready var reload_bar: ProgressBar = $Panel/ReloadProgress

@export var weapon_manager: WeaponManager

func _ready():
	reload_bar.visible = false
	# Connect to your WeaponManager (adjust path as needed)
	weapon_manager.weapon_changed.connect(update_weapon_info)
	weapon_manager.weapon_ammo_updated.connect(update_ammo)
	weapon_manager.weapon_reload_started.connect(start_reload_bar)
	weapon_manager.weapon_reload_finished.connect(stop_reload_bar)
	update_weapon_info(weapon_manager.get_current_weapon(), null)

func update_weapon_info(new_weapon: BaseWeapon, old_weapon: BaseWeapon):
	print('yep')
	weapon_name_label.text = new_weapon.weapon_name
	update_ammo(new_weapon.current_ammo, new_weapon.max_ammo)

func update_ammo(current_ammo: int, max_ammo: int):
	ammo_label.text = "%d / %d" % [current_ammo, max_ammo]

func start_reload_bar(reload_time: float):
	reload_bar.visible = true
	reload_bar.max_value = reload_time
	reload_bar.value = reload_time
	# Animate the progress bar
	var tween = create_tween()
	tween.tween_property(reload_bar, "value", 0.0, reload_time)

func stop_reload_bar():
	reload_bar.visible = false
