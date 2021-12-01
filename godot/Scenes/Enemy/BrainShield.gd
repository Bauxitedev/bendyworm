extends StaticBody

onready var sprite = $Sprite3D
var frame = 0
var fps = 24
onready var initial_sprite_color = get_sprite_color()
onready var health_holder = $HealthHolder
onready var flasher = $Sprite3D/Flasher

func set_sprite_color(value):
	var mat: ShaderMaterial = sprite.material_override
	mat.set_shader_param("albedo_color", value)
func get_sprite_color():
	var mat: ShaderMaterial = sprite.material_override
	return mat.get_shader_param("albedo_color")

func _process(delta):
	
	frame += fps * delta
	if frame > 23:
		frame = 0
		
	sprite.frame = floor(frame)
	
	if !flasher.is_flashing():
		set_sprite_color(initial_sprite_color * range_lerp(sin(4 * OS.get_ticks_msec() / 1000.0), -1, 1, 0.7, 1.0))


func _on_HealthHolder_on_death():
	Audio.play("ShieldBreak")
	FXSpawner.spawn("BrainShieldExplode", global_transform.origin, true)
	queue_free()


func _on_HealthHolder_on_hurt(_damage):
	flasher.flash()
