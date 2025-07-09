class_name HealthComponent
extends Node

@export var health_min: float = 0.0
@export var health_max: float = 100.0
@export var health_initial: float = health_max
@export var parent: Node

@onready var health: float = health_initial

signal health_changed(health: float, health_old: float)
signal damage_taken(damage: float)
signal died()
 
func set_health(new_value: float) -> float:
	var health_old = health
	
	health = clamp(new_value, health_min, health_max)
	health_changed.emit(health, health_old)
	print("health_changed ", health, " ", health_old)
	if health == health_min:
		die()
	
	return health

func take_damage(amount: float = .1) -> float:
	var damage = amount
	# NOTE Could apply damage reduction here
	
	damage_taken.emit(damage)
	set_health(health - damage)
	
	return damage

func die() -> bool:
	# NOTE Can refuse to die
	died.emit()
	ComponentUtils.get_component_parent(self).queue_free()
	
	return true
