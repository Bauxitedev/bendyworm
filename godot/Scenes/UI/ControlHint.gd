extends Sprite3D

var control_hint_type: String

func _ready():
	
	var mat: ShaderMaterial = material_override
	var tex
	
	match control_hint_type:
		"move_around": tex = preload("res://Textures/UI/ControlHintMoveAnim.tres")
		"jump": tex = preload("res://Textures/UI/ControlHintJumpAnim.tres")
		"shoot": tex = preload("res://Textures/UI/ControlHintShootAnim.tres")
		_: print("warning - unknown control hint type '%s'" % control_hint_type)
	mat.set_shader_param("albedo_texture", tex)


func _process(_delta):
	scale = Vector3.ONE * range_lerp(sin(OS.get_ticks_msec() / 1000.0), -1, 1, 0.9, 1.0)
	
	var brightness = range_lerp(fmod(OS.get_ticks_msec() / 1000.0, 2.0), 0, 2, 1.2, 0.6)
	var mat: ShaderMaterial = material_override
	mat.set_shader_param("albedo_color", Color(brightness, brightness, brightness))
