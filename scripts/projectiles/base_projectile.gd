class_name BaseProjectile
extends RigidBody3D

@export var lifetime := 2.0
@export var damage := 10
@export var bullet_hole_scene: PackedScene

var _timer := 0.0
var _last_position: Vector3

func _ready():
	# Set collision monitoring
	contact_monitor = true
	max_contacts_reported = 1
	_last_position = global_position

func initialize(speed: float, dmg: int, time: float = lifetime):
	damage = dmg
	lifetime = time
	linear_velocity = -global_transform.basis.z * speed

func hit(body: Node3D, at: Vector3, normal: Vector3 = Vector3.UP):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	if bullet_hole_scene:
		var new_bullet_hole = bullet_hole_scene.instantiate()
		body.add_child(new_bullet_hole)
		new_bullet_hole.global_position = at
		new_bullet_hole.look_at(at + normal, Vector3.UP) # Orient bullet hole to surface normal
		
	
	die()

func die():
	queue_free()

func _physics_process(delta):
	_timer += delta
	if _timer >= lifetime:
		die()
		return
	
	# Raycast check between frames
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		_last_position,
		global_position,
		1, # Explicitly set collision_mask to 1
		[self]  # Exclude self from raycast
	)
	
	var result = space_state.intersect_ray(query)
	if result:
		hit(result.collider, result.position, result.normal)
	
	_last_position = global_position

#func _on_body_entered(body):
	## Still keep this as backup for cases where raycast might miss
	#hit(body, global_position)
