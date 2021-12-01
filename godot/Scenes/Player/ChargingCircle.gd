extends Sprite3D

var circle_progress setget set_circle_progress, get_circle_progress

#func _process(delta):
	# Prevent flipping of the charging circle
	#global_transform.basis = global_transform.basis.orthonormalized()

func set_circle_progress(value):
	
	var epsilon = 1e-5
	value = clamp(value, epsilon, 1.0 - epsilon) 
		
	var mat: ShaderMaterial = material_override
	mat.set_shader_param("circle_progress", value)
	
func get_circle_progress():
	var mat: ShaderMaterial = material_override
	mat.get_shader_param("circle_progress")
