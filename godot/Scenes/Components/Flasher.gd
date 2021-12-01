extends Spatial

export var flash_time = 0.1
export var flash_brightness = 1.2
export var shake_amount = 10

onready var tween_idle = $TweenIdle
onready var flash_timer = $FlashTimer

var sprite_color: Color setget set_sprite_color, get_sprite_color
onready var target: Sprite3D = get_parent() # TODO assume target is always a Sprite3D
onready var initial_sprite_color = get_sprite_color()
onready var initial_sprite_pos = target.translation
var can_flash = true



func set_sprite_color(value):
	var mat: ShaderMaterial = target.material_override
	mat.set_shader_param("albedo_color", value)
func get_sprite_color():
	var mat: ShaderMaterial = target.material_override
	return mat.get_shader_param("albedo_color")

func _ready():
	target = get_parent()

func flash():
	if !can_flash:
		return
	
	var flash_color = initial_sprite_color * flash_brightness
	flash_color.a = initial_sprite_color.a  # Avoid alpha > 1.0 (causes visual glitches)
	
	var rand_offset = Vector3(rand_range(-1,1), rand_range(-1,1), rand_range(-1,1)).normalized() * rand_range(0, shake_amount)
	
	tween_idle.interpolate_property(self, "sprite_color", flash_color, initial_sprite_color, flash_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween_idle.interpolate_property(target, "translation", initial_sprite_pos + rand_offset, initial_sprite_pos, flash_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween_idle.start()
	
	can_flash = false

	flash_timer.start(flash_time)

func _on_FlashTimer_timeout():
	can_flash = true
	
func is_flashing():
	return !can_flash
