# utilities/weapon_manager.gd
class_name WeaponManager
extends Node

@export var starting_weapons: Array[PackedScene]
@export var weapon_positions: Array[NodePath]

var weapons: Array[BaseWeapon] = []
var current_weapon_index := 0

func _ready():
	for i in starting_weapons.size():
		add_weapon(starting_weapons[i], i)

func add_weapon(weapon_scene: PackedScene, slot: int):
	if slot >= weapon_positions.size():
		return
	
	var weapon = weapon_scene.instantiate()
	get_node(weapon_positions[slot]).add_child(weapon)
	weapons.append(weapon)
	
	# Hide all weapons except first
	weapon.visible = (slot == 0)

func switch_weapon(index: int):
	print('Switched to weapon #', index)
	if index >= weapons.size():
		return
	
	weapons[current_weapon_index].visible = false
	current_weapon_index = index
	weapons[current_weapon_index].visible = true

func get_current_weapon() -> BaseWeapon:
	if weapons.is_empty():
		return null
	return weapons[current_weapon_index]

func fire_current_weapon():
	var weapon = get_current_weapon()
	if weapon:
		weapon.fire()
