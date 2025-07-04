extends Node3D

@export var lifetime := 32.0
@export var mesh_instance: MeshInstance3D

var material: Material
var fade_timer := 0.0

func _ready():
	if !mesh_instance:
		push_warning("MeshInstance3D not assigned!")
		queue_free()
		return
	
	if !mesh_instance.mesh:
		push_warning("MeshInstance3D has no mesh!")
		queue_free()
		return
	
	# Get material (override first, then fall back to mesh default)
	material = mesh_instance.get_surface_override_material(0)
	if material == null:
		material = mesh_instance.mesh.surface_get_material(0)
	
	if !material:
		push_warning("No material found on mesh!")
		queue_free()
		return
	
	# Duplicate to avoid affecting other instances
	material = material.duplicate()
	mesh_instance.set_surface_override_material(0, material)
	
	# Enable transparency (if supported)
	if material is BaseMaterial3D:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX

func _process(delta):
	if !material:
		return
	
	fade_timer += delta
	var progress = clampf(fade_timer / lifetime, 0.0, 1.0)
	
	if material is BaseMaterial3D:
		var albedo = material.albedo_color
		material.albedo_color = Color(albedo.r, albedo.g, albedo.b, 1.0 - progress)
	elif material is ShaderMaterial:
		material.set_shader_parameter("alpha", 1.0 - progress)
	
	if progress >= 1.0:
		queue_free()
