extends HBoxContainer

onready var bar = $Bar
onready var icon = $Icon
onready var initial_bar_color: Color = get_bar_color()

export var flash_time = 0.2
var color_brightness_mul = 1.0
var can_flash = true

func _ready():
	Events.connect("on_player_spawn", self, "_events_on_player_spawn")	
	Events.connect("on_player_death", self, "_events_on_player_death")
	
func _physics_process(delta):
	color_brightness_mul = lerp(color_brightness_mul, 1.0, clamp(10.0 * delta, 0.0, 1.0))
	
func _process(_delta):
	
	var player = Globals.player
	if player == null:
		return
		
	var health_holder = player.health_holder

	if health_holder == null:
		print("warning - player health bar has null health holder")
		return
		
	if !health_holder.is_connected("on_hurt", self, "health_holder_on_hurt"):
		health_holder.connect("on_hurt", self, "health_holder_on_hurt")
	
	var ratio = health_holder.get_health_ratio()
	var low_hp_col = Color(initial_bar_color.g, initial_bar_color.r, initial_bar_color.b)
	
	var col = Globals.color_lerp_hsv(initial_bar_color, low_hp_col, 1.0 - ratio)
	col *= color_brightness_mul
	col.a = 1.0 # Prevent > 1.0 alpha
	
	set_bar_color(col)
	
	bar.value = health_holder.hp
	bar.max_value = health_holder.max_hp

func health_holder_on_hurt(_dmg):
	if !can_flash:
		return
		
	color_brightness_mul = 1.6
	can_flash = false
	
	$FlashTimer.start(flash_time)

func _on_FlashTimer_timeout():
	can_flash = true

func _events_on_player_spawn():
	icon.texture = preload("res://Textures/Heart.png")
	
func _events_on_player_death():
	icon.texture = preload("res://Textures/Death.png")

func set_bar_color(value):
	bar.get_stylebox("fg").bg_color = value
func get_bar_color():
	return bar.get_stylebox("fg").bg_color
	
	

