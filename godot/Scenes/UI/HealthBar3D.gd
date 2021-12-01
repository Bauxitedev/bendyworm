extends Spatial

export(NodePath) var health_holder_path

export var flash_time = 0.1
onready var health_holder = get_node(health_holder_path)
onready var bg = $BG
onready var fg = $BG/FG
onready var tween = $Tween

var can_flash = true

var color_brightness_mul = 1.0

onready var initial_sprite_color: Color = get_sprite_color()

func _ready():
	health_holder.connect("on_hurt", self, "health_holder_on_hurt")

func set_sprite_color(value):
	var mat: ShaderMaterial = fg.material_override
	mat.set_shader_param("albedo_color", value)
func get_sprite_color():
	var mat: ShaderMaterial = fg.material_override
	return mat.get_shader_param("albedo_color")
	
func _physics_process(delta):
	color_brightness_mul = lerp(color_brightness_mul, 1.0, clamp(10.0 * delta, 0.0, 1.0))

func _process(_delta):
	var ratio = health_holder.get_health_ratio()
	fg.scale.x = ratio
	
	var low_hp_col = Color(initial_sprite_color.g, initial_sprite_color.r, initial_sprite_color.b)
	
	var col = Globals.color_lerp_hsv(initial_sprite_color, low_hp_col, 1.0-ratio)
	
	col *= color_brightness_mul
	col.a = 1.0 # Avoid alpha > 1.0
	set_sprite_color(col)
	
func health_holder_on_hurt(_dmg):
	if !can_flash:
		return
		
	color_brightness_mul = 1.6
	can_flash = false
	
	$FlashTimer.start(flash_time)

func _on_FlashTimer_timeout():
	can_flash = true
