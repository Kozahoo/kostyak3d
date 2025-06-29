extends CharacterBody3D

# Movement settings
@export var move_speed := 6.0
@export var sprint_speed := 8.5
@export var acceleration := 2.5
@export var jump_velocity := 6.5
# Camera settings
@export var camera_sensitivity := .001
@export var camera_pitch_limit := deg_to_rad(45)

@onready var weapon_manager: WeaponManager = $WeaponManager

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Camera nodes
@onready var camera_pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera

# Movement state
var current_speed: float = 0.0
var is_sprinting := false
var direction := Vector3.ZERO

func _ready():
	# Hide and capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal rotation (left/right)
		rotate_y(-event.relative.x * camera_sensitivity)
		
		# Vertical rotation (up/down) - applied to camera pivot
		camera_pivot.rotate_x(-event.relative.y * camera_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -camera_pitch_limit, camera_pitch_limit)
	
	# Toggle mouse capture
	if event.is_action_pressed("cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Weapon switching
	if event.is_action_pressed("weapon_1"):
		weapon_manager.switch_weapon(0)
	if event.is_action_pressed("weapon_2"):
		weapon_manager.switch_weapon(1)

	# Firing
	if event.is_action_pressed("fire") or (weapon_manager.get_current_weapon() and weapon_manager.get_current_weapon().automatic and Input.is_action_pressed("fire")):
		weapon_manager.fire_current_weapon()

func _physics_process(delta):
	# Handle movement input first
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	is_sprinting = Input.is_action_pressed("sprint")

	# Calculate direction relative to where player is facing
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump - this should come BEFORE horizontal movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Only apply horizontal movement if we're on the floor or have control in air
	if is_on_floor() or (not is_on_floor() and direction.length() > 0):
		# Determine target speed
		var target_speed = sprint_speed if is_sprinting else move_speed

		# Smoothly adjust current speed toward target speed
		current_speed = lerp(current_speed, target_speed if direction else 0.0, acceleration * delta)

		# Apply horizontal movement
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			# Apply friction when no input
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _process(delta):
	return
	
	# Camera collision with environment
	var camera_target_pos = camera_pivot.transform.origin
	var camera_transform = camera.global_transform
	var space_state = get_world_3d().direct_space_state
	
	# Parameters for the raycast
	var origin = camera_pivot.global_transform.origin
	var end = camera.global_transform.origin
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Move camera forward if it hits something
		camera.transform.origin = camera.transform.origin.lerp(
			Vector3(0, 0, result.position.distance_to(origin) * 0.9),
			10.0 * delta
		)
	else:
		# Return to original position
		camera.transform.origin = camera.transform.origin.lerp(
			Vector3.ZERO,
			10.0 * delta
		)
