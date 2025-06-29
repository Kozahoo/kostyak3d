# projectiles/base_projectile.gd
class_name BaseProjectile
extends RigidBody3D

@export var lifetime := 2.0
@export var damage := 10

var _timer := 0.0

func _ready():
	# Set collision monitoring
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func initialize(speed: float, dmg: int, time: float = lifetime):
	damage = dmg
	lifetime = time
	linear_velocity = -global_transform.basis.z * speed

func _physics_process(delta):
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
