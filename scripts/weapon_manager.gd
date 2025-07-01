# utilities/weapon_manager.gd
class_name WeaponManager
extends Node

@export var starting_weapons: Array[PackedScene]
@export var weapon_positions: Array[NodePath]
@export var starting_equip_slot: int = 0

var weapons: Array[BaseWeapon] = []
var current_weapon_index := -1

signal weapon_changed(new_weapon: BaseWeapon, old_weapon: BaseWeapon)
# Signals that mirror the weapon's signals
signal weapon_fired()
signal weapon_ammo_updated(current_ammo: int, max_ammo: int)
signal weapon_reload_started(reload_time: float)
signal weapon_reload_finished()

func _ready():
	for i in starting_weapons.size():
		add_weapon(starting_weapons[i], i)
	switch_weapon(starting_equip_slot)
	connect_weapon_signals(get_current_weapon())

func connect_weapon_signals(weapon: BaseWeapon):
	if !weapon:
		return

	weapon.fired.connect(_on_weapon_fired)
	weapon.ammo_updated.connect(_on_weapon_ammo_updated)
	weapon.reload_started.connect(_on_weapon_reload_started)
	weapon.reload_finished.connect(_on_weapon_reload_finished)

func disconnect_weapon_signals(weapon: BaseWeapon):
	if !weapon:
		return

	weapon.fired.disconnect(_on_weapon_fired)
	weapon.ammo_updated.disconnect(_on_weapon_ammo_updated)
	weapon.reload_started.disconnect(_on_weapon_reload_started)
	weapon.reload_finished.disconnect(_on_weapon_reload_finished)

# Signal forwarders
func _on_weapon_fired():
	weapon_fired.emit()

func _on_weapon_ammo_updated(current: int, max_ammo: int):
	weapon_ammo_updated.emit(current, max_ammo)

func _on_weapon_reload_started(reload_time: float):
	weapon_reload_started.emit(reload_time)

func _on_weapon_reload_finished():
	weapon_reload_finished.emit()

func add_weapon(weapon_scene: PackedScene, slot: int):
	if slot >= weapon_positions.size():
		return
	
	var weapon = weapon_scene.instantiate()
	get_node(weapon_positions[slot]).add_child(weapon)
	weapons.append(weapon)
	
	# Hide all weapons except first
	weapon.visible = (slot == 0)

func switch_weapon(index: int):
	if( index == current_weapon_index or
		index >= weapons.size() ):
		return
	
	# Disconnect previous weapon signals
	var old_weapon = get_current_weapon()
	if old_weapon:
		disconnect_weapon_signals(old_weapon)
		old_weapon.reload_interrupt()

	weapons[current_weapon_index].visible = false
	current_weapon_index = index
	weapons[current_weapon_index].visible = true

	var new_weapon = get_current_weapon()
	connect_weapon_signals(new_weapon)
	
	new_weapon.equip()
	print('Switched to weapon #', index)
	weapon_changed.emit(new_weapon, old_weapon)

func get_current_weapon() -> BaseWeapon:
	if weapons.is_empty():
		return null
	return weapons[current_weapon_index]

func fire_current_weapon():
	var weapon = get_current_weapon()
	if weapon:
		weapon.fire()

func reload_current_weapon():
	var weapon = get_current_weapon()
	if weapon:
		weapon.reload()
